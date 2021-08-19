import qbs.File
import qbs.FileInfo
import qbs.ModUtils
import qbs.Probes
import qbs.Utilities

Product {
    name: "coverage-runner"
    type: ["out_html"]
    builtByDefault: false

    property stringList environment: ModUtils.flattenDictionary(qbs.commonRunEnvironment)
    property path lcovPath: lcovProbe.filePath
    property path genhtmlPath: genhtmlProbe.filePath

    Probes.BinaryProbe {
        id: lcovProbe
        names: "lcov"
    }

    Probes.BinaryProbe {
        id: genhtmlProbe
        names: "genhtml"
    }

    Depends {
        productTypes: "autotest"
        limitToSubProject: true
    }

    Rule {
        id: gcnoGenerator
        inputsFromDependencies: ["application"]
        outputFileTags: ["gcda"]
        outputArtifacts: {
            var artifacts = [];

            function traverse(dep) {
                var gcnos = dep.artifacts["gcno"] || [];
                gcnos.forEach(function(gcno) {
                    artifacts.push({
                        fileTags: ["gcda"],
                        filePath: FileInfo.joinPaths(FileInfo.path(gcno.filePath), gcno.completeBaseName + ".gcda")
                    });
                });
                dep.dependencies.forEach(traverse);
            }

            product.dependencies.forEach(traverse);
            return artifacts;
        }
        prepare: {
            if (!input.product.type.contains("autotest")) {
                var cmd = new JavaScriptCommand();
                cmd.silent = true;
                return cmd;
            }
            var commandFilePath;
            var installed = input.moduleProperty("qbs", "install");
            if (installed)
                commandFilePath = ModUtils.artifactInstalledFilePath(input);
            if (!commandFilePath || !File.exists(commandFilePath))
                commandFilePath = input.filePath;
            var arguments = (input.autotest && input.autotest.arguments && input.autotest.arguments.length > 0) ? input.autotest.arguments : [];
            var workingDir = (input.autotest && input.autotest.workingDir) ? input.autotest.workingDir : FileInfo.path(commandFilePath);
            var fullCommandLine = [].concat([commandFilePath]).concat(arguments);
            var cmd = new Command(fullCommandLine[0], fullCommandLine.slice(1));
            cmd.description = "running test " + input.fileName;
            cmd.environment = product.environment;
            cmd.workingDirectory = workingDir;
            cmd.jobPool = "coverage-runner";
            if (input.autotest && input.autotest.allowFailure)
                cmd.maxExitCode = 32767;
            return cmd;
        }
    }

    Rule {
        id: infoGenerator
        inputs: ["gcda"]
        outputFileTags: ["src_info"]
        outputArtifacts: {
            return [{
                fileTags: ["src_info"],
                filePath: FileInfo.joinPaths(Utilities.getHash(input.baseDir), input.fileName + ".info")
            }];
        }
        prepare: {
            var args = ["--quiet", "--capture"];
            args.push("--directory", FileInfo.path(input.filePath));
            args.push("--output-file", output.filePath);
            var cmd = new Command(product.lcovPath, args);
            cmd.description = "generating " + output.fileName;
            return cmd;
        }
    }

    Rule {
        id: infoMerger
        multiplex: true
        inputs: ["src_info"]
        outputFileTags: ["out_info"]
        outputArtifacts: {
            return [{
                fileTags: ["out_info"],
                filePath: FileInfo.joinPaths(product.destinationDirectory, product.targetName + ".info")
            }];
        }
        prepare: {
            var args = ["--quiet"];
            inputs.src_info.forEach(function(info) {
                args.push("--add-tracefile", info.filePath);
            });
            args.push("--output-file", output.filePath);
            var cmd = new Command(product.lcovPath, args);
            cmd.description = "generating " + output.fileName;
            return cmd;
        }
    }

    Rule {
        id: htmlGenerator
        inputs: ["out_info"]
        outputFileTags: ["out_html"]
        outputArtifacts: {
            return [{
                fileTags: ["out_html"],
                filePath: FileInfo.joinPaths(product.destinationDirectory, "html")
            }];
        }
        prepare: {
            var args = ["--quiet", "--ignore-errors"];
            args.push("source", input.filePath);
            args.push("--output-directory", output.filePath);
            var cmd = new Command(product.genhtmlPath, args);
            cmd.description = "generating html";
            return cmd;
        }
    }
}
