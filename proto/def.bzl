load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_proto//proto:defs.bzl", "ProtoInfo", "proto_common")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

ELM_PROTO_TOOLCHAIN = "@rules_elm//proto:toolchain_type"
INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION = getattr(proto_common, "INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION", False)


# _find_toolchain and _if_legacy_toolchain were copied from rules_proto
# if used as imports from rules_proto then an error occurs in bzlmod case
# their impl wants to retrieve e.g. rules_elm toolchain which is impossible
# from the context of rules_proto
def _find_toolchain(ctx, legacy_attr, toolchain_type):
    if INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION:
        toolchain = ctx.toolchains[toolchain_type]
        if not toolchain:
            fail("No toolchains registered for '%s'." % toolchain_type)
        return toolchain.proto
    else:
        return getattr(ctx.attr, legacy_attr)[proto_common.ProtoLangToolchainInfo]

def _if_legacy_toolchain(legacy_attr_dict):
    if INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION:
        return {}
    else:
        return legacy_attr_dict

def _well_known_proto(direct_srcs, well_known_protos):
    if direct_srcs:
        for well_known_proto in well_known_protos:
            candidate = direct_srcs[0]
            if (well_known_proto.basename == candidate.basename and
                well_known_proto.owner.package == candidate.owner.package and
                well_known_proto.owner.repo_name == candidate.owner.repo_name):
                return True
    return False

def _elm_proto_aspect_impl(target, ctx):

    proto_lang_toolchain_info = _find_toolchain(ctx, "_aspect_proto_toolchain", ELM_PROTO_TOOLCHAIN)
    proto_info = target[ProtoInfo]

    additional_args = ctx.actions.args()
    plugin_opts = [ctx.attr.plugin_opt_json, ctx.attr.plugin_opt_grpc, ctx.attr.plugin_opt_grpc]
    additional_args.add_all(
        [opt for opt in plugin_opts if opt],
        format_each = "--elm_opt=%s"
    )

    # skip "well-known-protos" which are handled by elm-protoc-types
    if proto_info.direct_sources and not _well_known_proto(proto_info.direct_sources, ctx.files._well_known_protos):
        generated_files = ctx.actions.declare_directory("Proto")
        elm_out = generated_files.dirname
        
        proto_common.compile(
            actions = ctx.actions,
            proto_info = proto_info,
            proto_lang_toolchain_info = proto_lang_toolchain_info,
            generated_files = [generated_files],
            plugin_output = elm_out,
            additional_args = additional_args,
        )

        elm_proto_toolchain_deps = ctx.toolchains[ELM_PROTO_TOOLCHAIN].deps if INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION else []

        return [
            _create_elm_library_provider(
                ctx.rule.attr.deps + elm_proto_toolchain_deps,
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
        "plugin_opt_json": attr.string(
            values = ["", "json", "json=encode", "json=decode"],
        ),
        "plugin_opt_grpc": attr.string(
            values = ["", "grpc", "grpc=false", "grpc=true"],
        ),
        "plugin_opt_grpc_dev": attr.string(
            values = ["", "grpcDevTools"],
        ),
        "_well_known_protos": attr.label(
            default = "@com_google_protobuf//:well_known_protos"
        )
    } | _if_legacy_toolchain({
        "_aspect_proto_toolchain": attr.label(
            default = ":default_elm_proto_toolchain",
        ),
    }),
    attr_aspects = ["deps"],
    required_providers = [ProtoInfo],
    provides = [_ElmLibrary],
    toolchains = [ELM_PROTO_TOOLCHAIN] if INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION else [],
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
              The `proto_library` rule to generate Elm libraries for.
              It must be any target providing `ProtoInfo`.""",
            mandatory = True,
            providers = [ProtoInfo],
            aspects = [_elm_proto_aspect],
        ),
        "plugin_opt_json": attr.string(
            doc = """
              Plugin opt which controls JSON encoders/decoders generation.
              One of: ["", "json", "json=encode", "json=decode"]
            """,
            default = "",
        ),
        "plugin_opt_grpc": attr.string(
            doc = """
              Plugin opt which controls GRPC related code generation.
              One of: ["", "grpc", "grpc=false", "grpc=true"]
            """,
            default = "",
        ),
        "plugin_opt_grpc_dev": attr.string(
            doc = """
              Plugin opt which controls grpc-dev-tools related code generation.
              One of: ["", "grpcDevTools"]
            """,
            default = "",
        ),
        "deps": attr.label_list(
            doc = """
              Possible Elm dependencies like elm-protoc-types or elm-protoc-utils
              which are required to compile generated code.
            """,
            default = [],
            providers = [_ElmLibrary],
        ),
    },
    provides = [_ElmLibrary],
)
