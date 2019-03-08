ElmLibrary = provider()

def _elm_binary_impl(ctx):
    toolchain = ctx.toolchains["@com_github_edschouten_rules_elm//elm:toolchain"]
    output = ctx.actions.declare_file(ctx.attr.name)
    deps_srcs = depset(transitive = [dep[ElmLibrary].transitive_srcs for dep in ctx.attr.deps])

    ctx.actions.run(
        mnemonic = "Elm",
        executable = "python3",
        arguments = [
            ctx.files._compile[0].path,
            toolchain.elm.files.to_list()[0].path,
            ctx.files.main[0].path,
        ],
        inputs = toolchain.elm.files + ctx.files._compile + ctx.files.main + deps_srcs,
        outputs = [output],
    )

    return [
        DefaultInfo(files = depset([output])),
    ]

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
    toolchains = ["@com_github_edschouten_rules_elm//elm:toolchain"],
    implementation = _elm_binary_impl,
)

def _elm_library_impl(ctx):
    return [
        ElmLibrary(
            transitive_srcs = depset(
                ctx.files.srcs,
                transitive = [dep[ElmLibrary].transitive_srcs for dep in ctx.attr.deps],
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
    },
    implementation = _elm_library_impl,
)
