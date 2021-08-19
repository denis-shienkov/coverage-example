import "qbs/imports/CoverageRunner.qbs" as CoverageRunner

Project {
    name: "coverage-example"
    qbsSearchPaths: "qbs"

    CoverageRunner { }

    references: [
        "src/src.qbs",
        "tests/tests.qbs"
    ]
}
