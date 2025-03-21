load("//elm/private:common.bzl", "get_workspace_root")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

def _paths_join(*args):
    return "/".join([path for path in args if path])

def _elm_library_impl(ctx):
    workspace_root = get_workspace_root(ctx)
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
    doc = """Declare a collection of Elm source files that can be reused
    by multiple `elm_binary()` targets.
    """,
    attrs = {
        "deps": attr.label_list(
            doc = """\
            List of `elm_library()` or `elm_package()` targets on which
  the library depends.
            """,
            providers = [_ElmLibrary]
        ),
        "srcs": attr.label_list(
            doc = """\
            List of source files to package together.
            """,
            allow_files = True,
            mandatory = True,
        ),
        "strip_import_prefix": attr.string(
            doc = """\
            Workspace root relative path prefix that should
            be removed from pathname resolution. For example, if the source file
            `my/project/Foo/Bar.elm` contains module `Foo.Bar`,
            `strip_import_prefix` should be set to `my/project` for module
            resolution to work.
            """,
        ),
    },
    implementation = _elm_library_impl,
)
