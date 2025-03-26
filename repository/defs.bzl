load("@bazel_tools//tools/build_defs/repo:utils.bzl", _patch = "patch")

# getting rid of the canonical repo name representation
# should be compatible with https://github.com/bazelbuild/bazel/issues/23127
def _fix_bzl_mod_repo_name(name):
    repo_name = name.split("~")[-1]
    if repo_name != name:
        return repo_name

    return name.split("+")[-1]

def _elm_repository_impl(rctx):
    rctx.download_and_extract(
        url = rctx.attr.urls,
        sha256 = rctx.attr.sha256,
        type = rctx.attr.type,
        stripPrefix = rctx.attr.strip_prefix,
    )
    _patch(rctx)

    metadata = json.decode(rctx.read("elm.json"))
    name_arg = rctx.attr.name

    deps = [
        "@elm_package_" + name.replace("/", "_").replace("-", "_")
        for name in metadata["dependencies"].keys()
    ]
    
    name = metadata["name"]
    substitutions = {
        "{{name}}": json.encode(_fix_bzl_mod_repo_name(name_arg)),
        "{{deps}}": json.encode(deps)
    }
    if name.startswith("elm/") or name.startswith("elm-explorations/"):
        # For official elm/* and elm-explorations/* packages, generate a
        # true elm_package(). These packages tend to rely on features
        # that are not exposed publicly (e.g., Elm.Kernel.*).
        substitutions = substitutions | {
            "{{package_name}}": json.encode(metadata["name"]),
            "{{package_version}}": json.encode(metadata["version"]),
        }
        rctx.template(
            "BUILD.bazel",
            rctx.attr._elm_package_tpl,
            substitutions = substitutions,
            executable = False,
        )
    else:
        # For other libraries, simply emit an elm_library(). This is
        # more useful in our case, as 'elm make' doesn't return sensible
        # errors about incorrect dependencies (e.g., version mismatches)
        # in our case. By declaring a library, we disable package
        # version checking entirely.
        rctx.template(
            "BUILD.bazel",
            rctx.attr._elm_library_tpl,
            substitutions = substitutions,
            executable = False,
        )

elm_repository = repository_rule(
    doc = """
    Downloads an Elm package over HTTP, extracts it and creates a
    `BUILD.bazel` file containing either an `elm_package()` or `elm_library()`
    declaration. For `elm/*` and `elm-explorations/*` an `elm_package()` is
    used. For others, `elm_library()` is used to prevent the Elm compiler
    from returning hard to debug dependency management related errors.
    """,
    attrs = {
        "urls": attr.string_list(
            doc = """\
            List of URLs where the package tarball may be downloaded.
            """,
        ),
        "strip_prefix": attr.string(
            doc = """\
            Directory prefix that may be removed from the files upon extraction.
            """,
        ),
        "type": attr.string(
            doc = """
            The archive type of the downloaded file. By default, the archive type is
            determined from the file extension of the URL. If the file has no extension,
            you can explicitly specify either "zip", "jar", "war", "aar", "nupkg", "tar",
            "tar.gz", "tgz", "tar.xz", "txz", ".tar.zst", ".tzst", "tar.bz2", ".tbz", ".ar",
            or ".deb" here. 
            """,
        ),
        "sha256": attr.string(
            doc = """\
            SHA-256 checksum of the tarball.
            """,
        ),
        # Patches to apply after extraction.
        "patches": attr.label_list(
            doc = """\
            List of labels of patches to apply after extraction.
            """,
        ),
        "patch_tool": attr.string(
            default = "patch"
        ),
        "patch_args": attr.string_list(
            default = ["-p0"]
        ),
        "patch_cmds": attr.string_list(
            default = []
        ),
        # build file templates
        "_elm_library_tpl": attr.label(
            default = Label("@rules_elm//repository:BUILD.bazel.elm_library.tpl")
        ),
        "_elm_package_tpl": attr.label(
            default = Label("@rules_elm//repository:BUILD.bazel.elm_package.tpl")
        )
    },
    implementation = _elm_repository_impl,
)
