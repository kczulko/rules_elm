ElmLibrary = provider()

_TOOLCHAIN = "@com_github_edschouten_rules_elm//elm:toolchain"

def _do_elm_make(ctx, outputs, js_path, elmi_path):
    toolchain = ctx.toolchains[_TOOLCHAIN]

    # Generate an elm.json file, containing a list of all package
    # dependencies and directories where sources are stored.
    source_directories = depset(
        transitive = [dep[ElmLibrary].source_directories for dep in ctx.attr.deps],
    )
    dependencies = {}
    for dep in ctx.attr.deps:
        for name, version in dep[ElmLibrary].dependencies:
            dependencies[name] = version
    elm_json = ctx.actions.declare_file(ctx.attr.name + "-elm.json")
    ctx.actions.write(
        elm_json,
        """{
    "type": "application",
    "dependencies": {"direct": %s, "indirect": {}},
    "elm-version": "0.19.0",
    "source-directories": %s,
    "test-dependencies": {"direct": {}, "indirect": {}}
}""" %
        (repr(dependencies), repr(source_directories.to_list())),
    )

    # Invoke Elm through a wrapper script that generates an ELM_HOME and
    # moves elm.json to the right spot prior to invocation.
    source_files = depset(
        transitive = [dep[ElmLibrary].source_files for dep in ctx.attr.deps],
    )
    package_directories = depset(
        transitive = [dep[ElmLibrary].package_directories for dep in ctx.attr.deps],
    )
    ctx.actions.run(
        mnemonic = "Elm",
        executable = "python",
        arguments = [
            ctx.files._compile[0].path,
            toolchain.elm.files.to_list()[0].path,
            elm_json.path,
            ctx.files.main[0].path,
            js_path,
            elmi_path,
        ] + package_directories.to_list(),
        inputs = toolchain.elm.files +
                 ctx.files._compile + [elm_json] + ctx.files.main +
                 source_files,
        outputs = outputs,
    )

def _elm_binary_impl(ctx):
    js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    _do_elm_make(ctx, [js_file], js_file.path, "unused.elmi")
    return [DefaultInfo(files = depset([js_file]))]

elm_binary = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "_compile": attr.label(
            allow_files = True,
            single_file = True,
            default = Label("@com_github_edschouten_rules_elm//elm:compile.py"),
        ),
    },
    toolchains = [_TOOLCHAIN],
    implementation = _elm_binary_impl,
)

def _get_workspace_root(ctx):
    if not ctx.label.workspace_root:
        return "."
    return ctx.label.workspace_root

def _elm_library_impl(ctx):
    source_directory = _get_workspace_root(ctx)
    if ctx.attr.strip_import_prefix:
        source_directory += "/" + ctx.attr.strip_import_prefix
    return [
        ElmLibrary(
            dependencies = depset(
                transitive = [dep[ElmLibrary].dependencies for dep in ctx.attr.deps],
            ),
            package_directories = depset(
                transitive = [
                    dep[ElmLibrary].package_directories
                    for dep in ctx.attr.deps
                ],
            ),
            source_directories = depset(
                [source_directory],
                transitive = [
                    dep[ElmLibrary].source_directories
                    for dep in ctx.attr.deps
                ],
            ),
            source_files = depset(
                ctx.files.srcs,
                transitive = [dep[ElmLibrary].source_files for dep in ctx.attr.deps],
            ),
        ),
    ]

elm_library = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "strip_import_prefix": attr.string(),
    },
    implementation = _elm_library_impl,
)

def _elm_package_impl(ctx):
    return [
        ElmLibrary(
            dependencies = depset(
                [(ctx.attr.package_name, ctx.attr.package_version)],
                transitive = [dep[ElmLibrary].dependencies for dep in ctx.attr.deps],
            ),
            package_directories = depset(
                [_get_workspace_root(ctx) + "/" + ctx.label.package],
                transitive = [
                    dep[ElmLibrary].package_directories
                    for dep in ctx.attr.deps
                ],
            ),
            source_directories = depset(
                transitive = [dep[ElmLibrary].source_directories for dep in ctx.attr.deps],
            ),
            source_files = depset(
                ctx.files.srcs,
                transitive = [dep[ElmLibrary].source_files for dep in ctx.attr.deps],
            ),
        ),
    ]

elm_package = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "package_name": attr.string(mandatory = True),
        "package_version": attr.string(mandatory = True),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
    },
    implementation = _elm_package_impl,
)

def _elm_test_impl(ctx):
    # Generate an .elmi file corresponding with the source file
    # containing the tests. This file contains a machine-readable list
    # of all top-level declarations.
    elmi_filename = ctx.files.main[0].basename
    if elmi_filename.endswith(".elm"):
        elmi_filename = elmi_filename[:-4]
    elmi_filename += ".elmi"
    elmi_file = ctx.actions.declare_file(elmi_filename)
    _do_elm_make(ctx, [elmi_file], "unused.js", elmi_file.path)

    # TODO(edsch): Convert .elmi to main source file.

    runner_filename = ctx.attr.name + "_start.sh"
    runner_file = ctx.actions.declare_file(runner_filename)
    ctx.actions.write(
        runner_file,
        "#!/bin/sh\necho Hello world\n",
        is_executable = True,
    )

    return [DefaultInfo(
        executable = runner_file,
        runfiles = ctx.runfiles([elmi_file]),
    )]

elm_test = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "_compile": attr.label(
            allow_files = True,
            single_file = True,
            default = Label("@com_github_edschouten_rules_elm//elm:compile.py"),
        ),
    },
    test = True,
    toolchains = [_TOOLCHAIN],
    implementation = _elm_test_impl,
)
