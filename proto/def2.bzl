load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_proto//proto:defs.bzl", "ProtoInfo", "proto_common")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

_WELL_KNOWN_PROTOS = [
    "google/protobuf/timestamp.proto",
    "google/protobuf/wrappers.proto",
]

ELM_PROTO_TOOLCHAIN = "@com_github_edschouten_rules_elm//proto:toolchain_type"

def _incompatible_toolchains_enabled():
    return getattr(proto_common, "INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION", False)

def _elm_proto_aspect_impl(target, ctx):
    if _incompatible_toolchains_enabled():
        toolchain = ctx.toolchains[ELM_PROTO_TOOLCHAIN]
        if not toolchain:
            fail("No toolchains registered for '%s'." % ELM_PROTO_TOOLCHAIN)
        proto_lang_toolchain_info = toolchain.proto
    else:
        proto_lang_toolchain_info = getattr(ctx.attr, "_aspect_proto_toolchain")[proto_common.ProtoLangToolchainInfo]

    proto_info = target[ProtoInfo]
    proto_root = proto_info.proto_source_root

    # additional_args = ctx.actions.args()
    # additional_args.add_all(
    #     [opt for opt in [ctx.attr.plugin_opt_json, ctx.attr.plugin_opt_grpc] if opt],
    #     format_each = "--elm_opt=%s"
    # )

    if proto_info.direct_sources:
        # Handles multiple repository and virtual import cases
        if proto_root.startswith(ctx.bin_dir.path):
            proto_root = proto_root[len(ctx.bin_dir.path) + 1:]

        elm_proto_files = paths.join(proto_root, "Proto")
        generated_files = ctx.actions.declare_directory(elm_proto_files)
        elm_out = paths.join(ctx.bin_dir.path, proto_root)
        
        proto_common.compile(
            actions = ctx.actions,
            proto_info = proto_info,
            proto_lang_toolchain_info = proto_lang_toolchain_info,
            generated_files = [generated_files],
            plugin_output = elm_out,
            # additional_args = additional_args,
        )

        return [
            _create_elm_library_provider(
                ctx.rule.attr.deps,
                [],
                [],
                [elm_out],
                [generated_files],
            ),
        ]
    else:
        # No source files to build, as all of them correspond with
        # built-in types.
        return [
            _create_elm_library_provider([], [], [], [], []),
        ]

_elm_proto_aspect = aspect(
    implementation = _elm_proto_aspect_impl,
    attrs = {
        # "plugin_opt_json": attr.string(
            # values = ["", "json", "json=encode", "json=decode"]
        # ),
        # "plugin_opt_grpc": attr.string(
            # values = ["", "grpc", "grpc=false", "grpc=true"]
        # ),
    } | ({} if _incompatible_toolchains_enabled() else {
        "_aspect_proto_toolchain": attr.label(
            default = ":default_elm_proto_toolchain",
        ),
    }),
    attr_aspects = ["deps"],
    required_providers = [ProtoInfo],
    provides = [_ElmLibrary],
    toolchains = [ELM_PROTO_TOOLCHAIN] if _incompatible_toolchains_enabled() else [],
)

def _elm_proto_library_rule(ctx):
    aspect_elm_lib = ctx.attr.proto[_ElmLibrary]
    return _create_elm_library_provider(
        ctx.attr.deps,
        aspect_elm_lib.dependencies.to_list(),
        aspect_elm_lib.package_directories.to_list(),
        aspect_elm_lib.source_directories.to_list(),
        aspect_elm_lib.source_files.to_list(),
    )

elm_proto_library = rule(
    implementation = _elm_proto_library_rule,
    doc = """""",
    attrs = {
        "proto": attr.label(
            doc = """
              The list of `proto_library` rules to generate Python libraries for.

              Usually this is just the one target: the proto library of interest.
              It can be any target providing `ProtoInfo`.""",
            providers = [ProtoInfo],
            aspects = [_elm_proto_aspect],
        ),
        "deps": attr.label_list(
            providers = [_ElmLibrary],
        ),
    },
    provides = [_ElmLibrary],
)


