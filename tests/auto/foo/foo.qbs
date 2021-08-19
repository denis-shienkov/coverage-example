CppApplication {
    name: "tst_foo"
    type: base.concat("autotest")
    Depends { name: "Qt"; submodules: ["test"] }
    Depends { name: "foo" }

    files: ["tst_foo.cpp"]
}
