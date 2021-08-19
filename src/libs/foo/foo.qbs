StaticLibrary {
    name: "foo"
    Depends { name: "cpp" }
    Depends { name: "coverage" }
    Depends { name: "Qt"; submodules: "core" }

    files: [ "foo.cpp", "foo.h" ]

    property string libIncludeBase: ".."
    cpp.includePaths: [libIncludeBase]

    Export {
        Depends { name: "cpp" }
        Depends { name: "coverage" }
        cpp.includePaths: [product.libIncludeBase]
    }
}
