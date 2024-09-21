def _elm_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        elm = ctx.attr.elm,
    )]

elm_toolchain = rule(
    attrs = {
        "elm": attr.label(
            allow_files = True,
            mandatory = True,
        ),
    },
    implementation = _elm_toolchain_impl,
)

