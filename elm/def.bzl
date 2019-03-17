ElmLibrary = provider()

_TOOLCHAIN = "@com_github_edschouten_rules_elm//elm:toolchain"

def _do_elm_make(
        ctx,
        main,
        additional_source_directories,
        additional_source_files,
        outputs,
        js_path,
        elmi_path,
        suffix):
    toolchain = ctx.toolchains[_TOOLCHAIN]

    # Generate an elm.json file, containing a list of all package
    # dependencies and directories where sources are stored.
    source_directories = depset(
        additional_source_directories,
        transitive = [dep[ElmLibrary].source_directories for dep in ctx.attr.deps],
    )
    dependencies = {}
    for dep in ctx.attr.deps:
        for name, version in dep[ElmLibrary].dependencies:
            dependencies[name] = version
    elm_json = ctx.actions.declare_file(ctx.attr.name + "-elm.json" + suffix)
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
        additional_source_files,
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
            main.path,
            js_path,
            elmi_path,
        ] + package_directories.to_list(),
        inputs = toolchain.elm.files +
                 ctx.files._compile + [elm_json, main] + source_files,
        outputs = outputs,
    )

def _elm_binary_impl(ctx):
    js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    _do_elm_make(
        ctx,
        ctx.files.main[0],
        [],
        [],
        [js_file],
        js_file.path,
        "unused.elmi",
        "",
    )
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
    _do_elm_make(
        ctx,
        ctx.files.main[0],
        [],
        [],
        [elmi_file],
        "unused.js",
        elmi_file.path,
        "-1",
    )

    # Create a main source file for the test that runs all the tests.
    # Obtain the list of tests to run from the .elmi file.
    main_filename = ctx.attr.name + "_main.elm"
    main_file = ctx.actions.declare_file(main_filename)
    ctx.actions.run(
        mnemonic = "Elmi2Main",
        executable = "python",
        arguments = [
            ctx.files._generate_test_main[0].path,
            elmi_file.path,
            main_file.path,
        ],
        inputs = ctx.files._generate_test_main + [elmi_file],
        outputs = [main_file],
    )

    # Build the new main file.
    js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    _do_elm_make(
        ctx,
        main_file,
        [ctx.files.main[0].dirname],
        ctx.files.main,
        [js_file],
        js_file.path,
        "unused.elmi",
        "-2",
    )

    runner_filename = ctx.attr.name + ".sh"
    runner_file = ctx.actions.declare_file(runner_filename)
    ctx.actions.write(runner_file, "#!/bin/sh\necho Hello world\n", is_executable = True)

    return [DefaultInfo(executable = runner_file, runfiles = ctx.runfiles([js_file]))]

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
        "_generate_test_main": attr.label(
            allow_files = True,
            single_file = True,
            default = Label(
                "@com_github_edschouten_rules_elm//elm:generate_test_main.py",
            ),
        ),
    },
    test = True,
    toolchains = [_TOOLCHAIN],
    implementation = _elm_test_impl,
)
