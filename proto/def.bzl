load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_proto//proto:defs.bzl", "ProtoInfo", "proto_common")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

ELM_PROTO_TOOLCHAIN = "@com_github_edschouten_rules_elm//proto:toolchain_type"
ELM_PROTO_DEPS = [
    "@elm_package_eriktim_elm_protocol_buffers",
    "@elm_package_anmolitor_elm_protoc_types",
    "@elm_package_danfishgold_base64_bytes",
    "@elm_package_elm_file",
    "@elm_package_elm_http",
    "@elm_package_elm_parser",
    "@elm_package_anmolitor_elm_protoc_utils",
    "@elm_package_rtfeldman_elm_iso8601_date_strings",
]

def _incompatible_toolchains_enabled():
    return getattr(proto_common, "INCOMPATIBLE_ENABLE_PROTO_TOOLCHAIN_RESOLUTION", False)

# skip "well-known-protos" which are handled by elm-protoc-types
def _well_known_proto(direct_srcs):
    return (direct_srcs and
        direct_srcs[0].owner.package == "src/google/protobuf" and
        direct_srcs[0].owner.repo_name.startswith("protobuf"))

def _elm_proto_aspect_impl(target, ctx):
    if _incompatible_toolchains_enabled():
        toolchain = ctx.toolchains[ELM_PROTO_TOOLCHAIN]
        if not toolchain:
            fail("No toolchains registered for '%s'." % ELM_PROTO_TOOLCHAIN)
        proto_lang_toolchain_info = toolchain.proto
    else:
        proto_lang_toolchain_info = getattr(ctx.attr, "_aspect_proto_toolchain")[proto_common.ProtoLangToolchainInfo]

    proto_info = target[ProtoInfo]

    additional_args = ctx.actions.args()
    plugin_opts = [ctx.attr.plugin_opt_json, ctx.attr.plugin_opt_grpc, ctx.attr.plugin_opt_grpc]
    additional_args.add_all(
        [opt for opt in plugin_opts if opt],
        format_each = "--elm_opt=%s"
    )

    if proto_info.direct_sources and not _well_known_proto(proto_info.direct_sources):
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
        "plugin_opt_json": attr.string(
            values = ["", "json", "json=encode", "json=decode"],
        ),
        "plugin_opt_grpc": attr.string(
            values = ["", "grpc", "grpc=false", "grpc=true"],
        ),
        "plugin_opt_grpc_dev": attr.string(
            values = ["", "grpcDevTools"],
        ),
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
              The `proto_library` rule to generate Python libraries for.
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
              which are required to compile generated code. Defaults to //proto:def.bzl:ELM_PROTO_DEPS
            """,
            default = ELM_PROTO_DEPS,
            providers = [_ElmLibrary],
        ),
    },
    provides = [_ElmLibrary],
)


