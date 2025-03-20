load("//elm/private:common.bzl", "do_elm_make", "ELM_TOOLCHAIN")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
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
        use_default_shell_env = True,
        inputs = ctx.files.main,
        outputs = [ tests_found_file ]
    )

    # Create a main source file for the test that runs all the tests.
    # Obtain the list of tests to run from the .elm file.
    main_filename = ctx.attr.name + "_main.elm"
    main_file = ctx.actions.declare_file(main_filename)
    ctx.actions.run(
        mnemonic = "ElmGenTest",
        executable = ctx.executable._generate_test_main,
        arguments = [
            module_name,
            tests_found_file.path,
            main_file.path,
        ],
        use_default_shell_env = True,
        inputs = ctx.files._generate_test_main + [tests_found_file],
        outputs = [main_file],
    )

    # Build the new main file.
    js_file_with_placeholders = ctx.actions.declare_file(ctx.attr.name + "_with_placehoders.js")
    do_elm_make(
        ctx,
        "fastbuild",
        main_file,
        ctx.attr.deps + [ctx.attr._node_test_runner],
        [ctx.files.main[0].dirname],
        ctx.files.main,
        [js_file_with_placeholders],
        js_file_with_placeholders.path,
        "-2",
    )

    # Placeholders removal
    # This is required to adapt the final file to run under nodejs
    # see: https://github.com/rtfeldman/node-test-runner/blob/eedf853fc9b45afd73a0db72decebdb856a69771/lib/Generate.js#L56-L74
    js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    ctx.actions.run(
        mnemonic = "EmlTestReplacePlacehoders",
        executable = ctx.executable._tests_placehoder_repairer,
        arguments = [
            js_file_with_placeholders.short_path,
            js_file.short_path
        ],
        env = {
            "BAZEL_BINDIR": ctx.bin_dir.path,
        },
        use_default_shell_env = True,
        inputs = [js_file_with_placeholders],
        outputs = [js_file]
    )

    runner_filename = ctx.attr.name + ".sh"
    runner_file = ctx.actions.declare_file(runner_filename)

    ctx.actions.write(
        runner_file,
        content = """#!/usr/bin/env bash

NODE_PATH=$PWD:$NODE_PATH exec {bin} {args}""".format(
            bin = ctx.executable._tests_runner.short_path,
            args = " ".join(["%s" % js_file.short_path])
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
            executable = True,
            cfg = "exec",
            default = Label("@rules_elm//elm/private:compile"),
        ),
        "_generate_test_main": attr.label(
            executable = True,
            cfg = "exec",
            default = Label("@rules_elm//elm/private:generate_test_main"),
        ),
        "_node_test_runner": attr.label(
            providers = [_ElmLibrary],
            default = Label("@com_github_rtfeldman_node_test_runner//:node_test_runner"),
        ),
        "_tests_finder": attr.label(
            allow_single_file = True,
            default = Label("@rules_elm//tools/tests-finder:bin"),
            executable = True,
            cfg = "exec"
        ),
        "_tests_placehoder_repairer": attr.label(
            allow_single_file = True,
            default = Label("@rules_elm//tools/tests-placeholder-repairer:bin"),
            executable = True,
            cfg = "exec"
        ),
        "_tests_runner": attr.label(
            allow_single_file = True,
            default = Label("@rules_elm//tools/tests-runner:bin"),
            executable = True,
            cfg = "exec"
        ),
    },
    test = True,
    toolchains = [ELM_TOOLCHAIN],
    implementation = _elm_test_impl,
)
