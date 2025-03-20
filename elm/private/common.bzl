load("//elm/private:providers.bzl", _ElmLibrary = "ElmLibrary")

ELM_TOOLCHAIN = "@rules_elm//elm:toolchain"

def get_workspace_root(ctx):
    if not ctx.label.workspace_root:
        return "."
    return ctx.label.workspace_root

def do_elm_make(
        ctx,
        compilation_mode,
        main,
        deps,
        additional_source_directories,
        additional_source_files,
        outputs,
        js_path,
        suffix):
    toolchain = ctx.toolchains[ELM_TOOLCHAIN]

    # Generate an elm.json file, containing a list of all package
    # dependencies and directories where sources are stored.
    source_directories = depset(
        additional_source_directories,
        transitive = [dep[_ElmLibrary].source_directories for dep in deps],
    )
    dependencies = {}
    for dep in deps:
        for name, version in dep[_ElmLibrary].dependencies.to_list():
            dependencies[name] = version
    elm_json = ctx.actions.declare_file(ctx.attr.name + "-elm.json" + suffix)
    # since 0.19.1, elm doesn't tolerate empty source-directories...
    source_dirs = source_directories.to_list() if source_directories else [ main.dirname ]
    ctx.actions.write(
        elm_json,
        """{
    "type": "application",
    "dependencies": {"direct": %s, "indirect": {}},
    "elm-version": "0.19.1",
    "source-directories": %s,
    "test-dependencies": {"direct": {}, "indirect": {}}
}""" %
        (repr(dependencies), repr(source_dirs)),
    )

    # Invoke Elm through a wrapper script that generates an ELM_HOME and
    # moves elm.json to the right spot prior to invocation.
    source_files = depset(
        additional_source_files,
        transitive = [dep[_ElmLibrary].source_files for dep in deps],
    )
    package_directories = depset(
        transitive = [dep[_ElmLibrary].package_directories for dep in deps],
    )
    toolchain_elm_files_list = toolchain.elm.files.to_list()

    ctx.actions.run(
        mnemonic = "Elm",
        executable = ctx.executable._compile,
        arguments = [
            compilation_mode,
            toolchain_elm_files_list[0].path,
            elm_json.path,
            main.path,
            js_path,
        ] + package_directories.to_list(),
        inputs = toolchain_elm_files_list +
                 ctx.files._compile + [elm_json, main] + source_files.to_list(),
        outputs = outputs,
    )

