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
    # since 0.19.1 elm doesn't tolerate empty source-directories...
    # TODO: move to source_directories
    source_dirs = [ main.dirname ] if source_directories.to_list() == [] else source_directories.to_list()
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
                js1_file.basename,
                "--compress",
                "pure_funcs=[F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9],pure_getters,keep_fargs=false,unsafe_comps,unsafe",
                "--output",
                js2_file.basename,
            ],
            env = {
                "BAZEL_BINDIR": ctx.bin_dir.path,
            },
            inputs = [js1_file],
            outputs = [js2_file],
        )

        # Step 3: Mangle the resulting Javascript.
        ctx.actions.run(
            mnemonic = "UglifyJS",
            executable = ctx.executable._uglifyjs,
            arguments = [
                js2_file.basename,
                "--mangle",
                "--output",
                js_file.basename,
            ],
            env = {
                "BAZEL_BINDIR": ctx.bin_dir.path,
            },
            inputs = [js2_file],
            outputs = [js_file],
        )
    else:
        print("I am here")
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
            default = Label("@com_github_edschouten_rules_elm//tools/uglifyjs:bin"),
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
    module_name = ctx.files.main[0].basename[:-4]

    # Find tests:
    tests_found_filename = ctx.attr.name + "_tests_found.json"
    tests_found_file = ctx.actions.declare_file(tests_found_filename)
    ctx.actions.run_shell(
        mnemonic = "EmlFindTests",
        tools = [
            ctx.executable._tests_finder
        ],
        command = "exec %s $(readlink -f %s) $(pwd)/%s\n" % (ctx.executable._tests_finder.path, ctx.files.main[0].short_path, tests_found_file.path),
        env = {
            "BAZEL_BINDIR": ctx.bin_dir.path,
        },
        inputs = ctx.files.main,
        outputs = [ tests_found_file ]
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
            module_name,
            tests_found_file.path,
            main_file.path,
        ],
        inputs = ctx.files._generate_test_main + [tests_found_file],
        outputs = [main_file],
    )

    # Build the new main file.
    js_file_with_placeholders = ctx.actions.declare_file(ctx.attr.name + "_with_placehoders.js")
    _do_elm_make(
        ctx,
        "fastbuild",
        main_file,
        ctx.attr.deps + [ctx.attr._node_test_runner],
        [ctx.files.main[0].dirname],
        ctx.files.main,
        [js_file_with_placeholders],
        js_file_with_placeholders.path,
        "",
        "-2",
    )

    # Placeholders removal
    # This is required to adapt the final file to run under nodejs
    # see: https://github.com/rtfeldman/node-test-runner/blob/eedf853fc9b45afd73a0db72decebdb856a69771/lib/Generate.js#L56-L74
    js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    ctx.actions.run_shell(
        mnemonic = "EmlTestReplacePlacehoders",
        tools = [ ctx.executable._tests_placehoder_repairer ],
        command = "exec %s $(readlink -f %s) $(pwd)/%s\n" % (ctx.executable._tests_placehoder_repairer.path, js_file_with_placeholders.path, js_file.path),
        env = {
            "BAZEL_BINDIR": ctx.bin_dir.path,
        },
        inputs = [ js_file_with_placeholders ],
        outputs = [ js_file ]
    )

    runner_filename = ctx.attr.name + ".sh"
    runner_file = ctx.actions.declare_file(runner_filename)

    ctx.actions.write(
        runner_file,
        content = """
#!/usr/bin/env bash
exec {bin} {args}""".format(
            bin = ctx.executable._tests_runner.short_path,
            args = " ".join(["$(pwd)/%s" % js_file.short_path])
        ),
        is_executable = True,
    )

    return [DefaultInfo(
        executable = runner_file,
        runfiles = ctx.runfiles([js_file]).merge(ctx.attr._tests_runner.default_runfiles),
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
        "_node_test_runner": attr.label(
            providers = [_ElmLibrary],
            default = Label(
                "@com_github_rtfeldman_node_test_runner//:node_test_runner",
            ),
        ),
        "_tests_finder": attr.label(
            allow_single_file = True,
            default = Label("@com_github_edschouten_rules_elm//tools/tests-finder:bin"),
            executable = True,
            cfg = "exec"
        ),
        "_tests_placehoder_repairer": attr.label(
            allow_single_file = True,
            default = Label("@com_github_edschouten_rules_elm//tools/tests-placeholder-repairer:bin"),
            executable = True,
            cfg = "exec"
        ),
        "_tests_runner": attr.label(
            allow_single_file = True,
            default = Label("@com_github_edschouten_rules_elm//tools/tests-runner:bin"),
            executable = True,
            cfg = "exec"
        ),
    },
    test = True,
    toolchains = [_TOOLCHAIN],
    implementation = _elm_test_impl,
)
