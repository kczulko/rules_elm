load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

_TOOLCHAIN = "@com_github_edschouten_rules_elm//elm:toolchain"

def _do_elm_make(
        ctx,
        compilation_mode,
        main,
        deps,
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
        transitive = [dep[_ElmLibrary].source_directories for dep in deps],
    )
    dependencies = {}
    for dep in deps:
        for name, version in dep[_ElmLibrary].dependencies.to_list():
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
        transitive = [dep[_ElmLibrary].source_files for dep in deps],
    )
    package_directories = depset(
        transitive = [dep[_ElmLibrary].package_directories for dep in deps],
    )
    toolchain_elm_files_list = toolchain.elm.files.to_list()
    ctx.actions.run(
        mnemonic = "Elm",
        executable = "python",
        arguments = [
            ctx.files._compile[0].path,
            compilation_mode,
            toolchain_elm_files_list[0].path,
            elm_json.path,
            main.path,
            js_path,
            elmi_path,
        ] + package_directories.to_list(),
        inputs = toolchain_elm_files_list +
                 ctx.files._compile + [elm_json, main] + source_files.to_list(),
        outputs = outputs,
    )

def _elm_binary_impl(ctx):
    js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    compilation_mode = ctx.var["COMPILATION_MODE"]
    if compilation_mode == "opt":
        # Step 1: Compile the Elm code.
        js1_file = ctx.actions.declare_file(ctx.attr.name + ".1.js")
        _do_elm_make(
            ctx,
            compilation_mode,
            ctx.files.main[0],
            ctx.attr.deps,
            [],
            [],
            [js1_file],
            js1_file.path,
            "",
            "",
        )

        # Step 2: Compress the resulting Javascript.
        js2_file = ctx.actions.declare_file(ctx.attr.name + ".2.js")
        ctx.actions.run(
            mnemonic = "UglifyJS",
            executable = ctx.executable._uglifyjs,
            arguments = [
                js1_file.path,
                "--compress",
                "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe",
                "--output",
                js2_file.path,
            ],
            inputs = [js1_file],
            outputs = [js2_file],
        )

        # Step 3: Mangle the resulting Javascript.
        ctx.actions.run(
            mnemonic = "UglifyJS",
            executable = ctx.executable._uglifyjs,
            arguments = [
                js2_file.path,
                "--mangle",
                "--output",
                js_file.path,
            ],
            inputs = [js2_file],
            outputs = [js_file],
        )
    else:
        # Don't attempt to compress the code after building.
        _do_elm_make(
            ctx,
            compilation_mode,
            ctx.files.main[0],
            ctx.attr.deps,
            [],
            [],
            [js_file],
            js_file.path,
            "",
            "",
        )
    return [DefaultInfo(files = depset([js_file]))]

elm_binary = rule(
    attrs = {
        "deps": attr.label_list(providers = [_ElmLibrary]),
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "_compile": attr.label(
            allow_single_file = True,
            default = Label("@com_github_edschouten_rules_elm//elm:compile.py"),
        ),
        "_uglifyjs": attr.label(
            cfg = "host",
            default = Label("@npm//uglify-js/bin:uglifyjs"),
            executable = True,
        ),
    },
    toolchains = [_TOOLCHAIN],
    implementation = _elm_binary_impl,
)

def _get_workspace_root(ctx):
    if not ctx.label.workspace_root:
        return "."
    return ctx.label.workspace_root

def _paths_join(*args):
    return "/".join([path for path in args if path])

def _elm_library_impl(ctx):
    workspace_root = _get_workspace_root(ctx)
    source_directories_set = {}
    for src in ctx.files.srcs:
        source_directories_set.setdefault(_paths_join(
            workspace_root,
            src.root.path,  # non-empty for generated files.
            ctx.attr.strip_import_prefix,
        ))
    source_directories = source_directories_set.keys()
    return [
        _create_elm_library_provider(
            ctx.attr.deps,
            [],
            [],
            source_directories,
            ctx.files.srcs,
        ),
    ]

elm_library = rule(
    attrs = {
        "deps": attr.label_list(providers = [_ElmLibrary]),
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
        _create_elm_library_provider(
            ctx.attr.deps,
            [(ctx.attr.package_name, ctx.attr.package_version)],
            [_get_workspace_root(ctx) + "/" + ctx.label.package],
            [],
            ctx.files.srcs,
        ),
    ]

elm_package = rule(
    attrs = {
        "deps": attr.label_list(providers = [_ElmLibrary]),
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
        "fastbuild",
        ctx.files.main[0],
        ctx.attr.deps,
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
        "fastbuild",
        main_file,
        ctx.attr.deps + [ctx.attr._node_test_runner],
        [ctx.files.main[0].dirname],
        ctx.files.main,
        [js_file],
        js_file.path,
        "",
        "-2",
    )

    runner_filename = ctx.attr.name + ".sh"
    runner_file = ctx.actions.declare_file(runner_filename)
    ctx.actions.write(
        runner_file,
        "#!/bin/sh\nexec %s %s $(pwd)/%s\n" % (ctx.files._node[0].short_path, ctx.files._run_test[0].short_path, js_file.short_path),
        is_executable = True,
    )

    return [DefaultInfo(
        executable = runner_file,
        runfiles = ctx.runfiles(ctx.files._node + ctx.files._run_test + [js_file]),
    )]

elm_test = rule(
    attrs = {
        "deps": attr.label_list(providers = [_ElmLibrary]),
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "_compile": attr.label(
            allow_single_file = True,
            default = Label("@com_github_edschouten_rules_elm//elm:compile.py"),
        ),
        "_generate_test_main": attr.label(
            allow_single_file = True,
            default = Label(
                "@com_github_edschouten_rules_elm//elm:generate_test_main.py",
            ),
        ),
        "_node": attr.label(
            allow_single_file = True,
            default = Label("@nodejs//:node"),
        ),
        "_node_test_runner": attr.label(
            providers = [_ElmLibrary],
            default = Label(
                "@com_github_rtfeldman_node_test_runner//:node_test_runner",
            ),
        ),
        "_run_test": attr.label(
            allow_single_file = True,
            default = Label("@com_github_edschouten_rules_elm//elm:run_test.js"),
        ),
    },
    test = True,
    toolchains = [_TOOLCHAIN],
    implementation = _elm_test_impl,
)
