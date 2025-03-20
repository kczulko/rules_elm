load("//elm/private:common.bzl", "do_elm_make", "ELM_TOOLCHAIN")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

def _elm_binary_impl(ctx):
    js_file = ctx.actions.declare_file(ctx.attr.name + ".js")
    compilation_mode = ctx.var["COMPILATION_MODE"]
    if compilation_mode == "opt":
        # Step 1: Compile the Elm code.
        js1_file = ctx.actions.declare_file(ctx.attr.name + ".1.js")
        do_elm_make(
            ctx,
            compilation_mode,
            ctx.files.main[0],
            ctx.attr.deps,
            [],
            [],
            [js1_file],
            js1_file.path,
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
            # rules_js is using uname and dirname
            # see here: https://github.com/aspect-build/rules_js/blob/4488c9ff72efc4052fc338fc9fd28a1bad19fd1d/js/private/js_binary.sh.tpl#L365
            use_default_shell_env = True,
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
            # rules_js is using uname and dirname
            # see here: https://github.com/aspect-build/rules_js/blob/4488c9ff72efc4052fc338fc9fd28a1bad19fd1d/js/private/js_binary.sh.tpl#L365
            use_default_shell_env = True,
            env = {
                "BAZEL_BINDIR": ctx.bin_dir.path,
            },
            inputs = [js2_file],
            outputs = [js_file],
        )
    else:
        # Don't attempt to compress the code after building.
        do_elm_make(
            ctx,
            compilation_mode,
            ctx.files.main[0],
            ctx.attr.deps,
            [],
            [],
            [js_file],
            js_file.path,
            "",
        )
    return [DefaultInfo(files = depset([js_file]))]

elm_binary = rule(
    doc = """Transpiles an Elm application to Javascript.
    The resulting Javascript file will be named `${name}.js`.

    ```starlark
    load("@rules_elm//elm:defs.bzl", "elm_binary")

    elm_binary(
       name = "bin",
       main = "Main.elm",
       deps = [
           "@elm_package_elm_core",
           "@elm_package_elm_html",
           "@elm_package_elm_json",
           "@elm_package_elm_virtual_dom",
       ],
    )
    ```

    **Note:** When the compilation mode (`-c`) is equal to `dbg`, the
    resulting Javascript file will have the time traveling debugger enabled.
    When the compilation mode is `opt`, optimizations are performed and the
    resulting code is minified using UglifyJS.
    """,
    attrs = {
        "deps": attr.label_list(
            providers = [_ElmLibrary],
            doc = """\
            List of `elm_library()` or `elm_package()` targets
            on which the application depends.
            """,
        ),
        "main": attr.label(
            doc = """\
            The name of the source file containing the
            [`Program`](https://package.elm-lang.org/packages/elm/core/latest/Platform#Program).
            """,
            allow_files = True,
            mandatory = True,
        ),
        "_compile": attr.label(
            cfg = "exec",
            default = Label("@rules_elm//elm/private:compile"),
            executable = True,
        ),
        "_uglifyjs": attr.label(
            cfg = "exec",
            default = Label("@rules_elm//tools/uglifyjs:bin"),
            executable = True,
        ),
    },
    toolchains = [ELM_TOOLCHAIN],
    implementation = _elm_binary_impl,
)
