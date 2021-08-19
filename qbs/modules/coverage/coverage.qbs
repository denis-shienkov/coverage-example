import qbs.FileInfo
import qbs.Utilities

Module {
    condition: qbs.debugInformation && qbs.toolchain.contains("gcc")
    additionalProductTypes: ["gcno"]
    Depends { name: "cpp" }
    cpp.driverFlags: ["--coverage"]

    Rule { // Fake rule for '*.gcno' generation.
        inputs: ["cpp", "c"]
        outputFileTags: ["gcno"]
        outputArtifacts: {
            return [{
                fileTags: ["gcno"],
                filePath: FileInfo.joinPaths(Utilities.getHash(input.baseDir),
                                             input.fileName + ".gcno")
            }];
        }
        prepare: {
            var cmd = new JavaScriptCommand();
            cmd.description = "generating " + output.fileName;
            return [cmd];
        }
    }
}
