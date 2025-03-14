load("@com_google_protobuf//bazel/common:proto_common.bzl", "proto_common")
load("@rules_elm//proto:defs.bzl", "ELM_PROTO_TOOLCHAIN")
load(
    "@rules_elm//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
)

def _elm_proto_toolchain_impl(ctx):
    proto_lang_toolchain = proto_common.ProtoLangToolchainInfo(
        out_replacement_format_flag = ctx.attr.out_replacement_format_flag,
        plugin_format_flag = ctx.attr.plugin_format_flag,
        plugin = ctx.attr.plugin.files_to_run,
        runtime = None,
        provided_proto_sources = depset(),
        proto_compiler = ctx.attr.proto_compiler.files_to_run if ctx.attr.proto_compiler else ctx.attr._default_proto_compiler.files_to_run,
        protoc_opts = ctx.attr.protoc_opts,
        progress_message = "ElmGenProto %{label}",
        mnemonic = "ElmGenProto",
        toolchain_type = ELM_PROTO_TOOLCHAIN,
    )

    return [
        DefaultInfo(files = depset(), runfiles = ctx.runfiles()),
        platform_common.ToolchainInfo(proto = proto_lang_toolchain, deps = ctx.attr.deps),
    ]

elm_proto_toolchain = rule(
    implementation = _elm_proto_toolchain_impl,
    doc = "Elm protobuf toolchain rule.",
    fragments = ["proto"],
    attrs = {
        "out_replacement_format_flag": attr.string(
            default = "--elm_out=%s",
        ),
        "plugin_format_flag": attr.string(
            default = "--plugin=protoc-gen-elm=%s",
        ),
        "plugin": attr.label(
            cfg = "exec",
            executable = True,
            allow_files = True,
            default = "@rules_elm//tools/protoc-gen-elm:bin",
        ),
        "proto_compiler": attr.label(
            cfg = "exec",
            executable = True,
            allow_files = True,
        ),
        "protoc_opts": attr.string_list(),
        "deps": attr.label_list(
            default = [],
            providers = [_ElmLibrary]
        ),
        "_default_proto_compiler": attr.label(
            cfg = "exec",
            executable = True,
            allow_files = True,
            default = configuration_field(fragment = "proto", name = "proto_compiler"),
        ),
    },
    provides = [platform_common.ToolchainInfo],
)
