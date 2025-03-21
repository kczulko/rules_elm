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
    doc = """Makes an off-the-shelf Elm package usable as a dependency.

    **Note:** This function is typically not used directly; it is often
sufficient to use `elm_repository()`.
    """,
    attrs = {
        "deps": attr.label_list(
            doc = """\
            List of packages on which this package depends.
            """,
            providers = [_ElmLibrary]
        ),
        "package_name": attr.string(
            doc = """\
            The publicly used name of the package (e.g., `elm/json`)
            """,
            mandatory = True
        ),
        "package_version": attr.string(
            doc = """\
            The version of the package (e.g., `1.0.2`).
            """,
            mandatory = True
        ),
        "srcs": attr.label_list(
            doc = """\
            Files that are part of this package. This list **SHOULD**
            include `"elm.json"`.
            """,
            allow_files = True,
            mandatory = True,
        ),
    },
    implementation = _elm_package_impl,
)
