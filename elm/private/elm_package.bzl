load("//elm/private:common.bzl", "get_workspace_root")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

def _elm_package_impl(ctx):
    return [
        _create_elm_library_provider(
            ctx.attr.deps,
            [(ctx.attr.package_name, ctx.attr.package_version)],
            [get_workspace_root(ctx) + "/" + ctx.label.package],
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
