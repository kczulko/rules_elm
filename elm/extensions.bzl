load("@com_github_edschouten_rules_elm//repository:def.bzl", "elm_repository")

load("@bazel_skylib//lib:sets.bzl", "sets")
load(":repositories.bzl", "elm_register_toolchains")

def _repository_fun(attrs):
    elm_repository(
        name = attrs.name,
        urls = attrs.urls,
        strip_prefix = attrs.strip_prefix,
        type = attrs.type,
        sha256 = attrs.sha256,
        patches = attrs.patches,
        patch_tool = attrs.patch_tool,
        patch_args = attrs.patch_args,
        patch_cmds = attrs.patch_cmds,
    )

def _toolchain_fun(attrs):
    elm_register_toolchains(register = False)

def _elm_module_extension_impl(module_ctx):
    root_direct_deps = sets.make()
    root_direct_dev_deps = sets.make()

    is_isolated = getattr(module_ctx, "is_isolated", False)

    for mod in module_ctx.modules:
        is_root = mod.is_root

        for repository in mod.tags.repository:
            _repository_fun(repository)
            if mod.is_root:
                deps = root_direct_dev_deps if module_ctx.is_dev_dependency(repository) else root_direct_deps
                sets.insert(deps, repository.name)

        for toolchain in mod.tags.toolchain:
            _toolchain_fun(toolchain)

    return module_ctx.extension_metadata(
        root_module_direct_deps = sets.to_list(root_direct_deps),
        root_module_direct_dev_deps = sets.to_list(root_direct_dev_deps),
    )

_repository_tag = tag_class(
    attrs = {
        "name": attr.string(),
        "urls": attr.string_list(),
        "strip_prefix": attr.string(),
        "type": attr.string(),
        "sha256": attr.string(),
        "patches": attr.label_list(),
        "patch_tool": attr.string(default = "patch"),
        "patch_args": attr.string_list(default = ["-p0"]),
        "patch_cmds": attr.string_list(default = []),
    }
)

_toolchain_tag = tag_class(
    attrs = {}
)

elm = module_extension(
    _elm_module_extension_impl,
    tag_classes = {
        "repository": _repository_tag,
        "toolchain": _toolchain_tag,
    },
)
