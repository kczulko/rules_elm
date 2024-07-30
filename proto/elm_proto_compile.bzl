load(
    "@rules_proto_grpc//:defs.bzl",
    "ProtoPluginInfo",
    "proto_compile_attrs",
    "proto_compile_impl",
)

elm_proto_compile = rule(
    implementation = proto_compile_impl,
    attrs = dict(
        proto_compile_attrs,
        _plugins = attr.label_list(
            providers = [ProtoPluginInfo],
            default = [
                Label(":protoc_gen_elm"),
            ],
            cfg = "exec",
            doc = "List of protoc plugins to apply",
        ),
    ),
    toolchains = ["@rules_proto_grpc//protoc:toolchain_type"],
)
