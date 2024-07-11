def _elm_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        elm = ctx.attr.elm,
    )]

_elm_toolchain = rule(
    attrs = {
        "elm": attr.label(
            allow_files = True,
            mandatory = True,
        ),
    },
    implementation = _elm_toolchain_impl,
)

def elm_toolchain(name, exec_compatible_with):
    native.genrule(
        name = "elm_compiler_{}".format(name),
        srcs = ["@com_github_elm_compiler_{}//file".format(name)],
        outs = [ "%s/elm-compiler" % name ],
        cmd = "gunzip -c $(SRCS) > $@ && chmod +x $@"
    )

    _elm_toolchain(
        name = name + "_info",
        elm = ":elm_compiler_{}".format(name),
        visibility = ["//visibility:public"],
    )

    native.toolchain(
        name = name,
        toolchain_type = "@com_github_edschouten_rules_elm//elm:toolchain",
        exec_compatible_with = exec_compatible_with,
        toolchain = ":%s_info" % name,
    )
