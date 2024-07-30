load("@com_github_edschouten_rules_elm//proto:generic_elm_proto_library.bzl", "generic_elm_proto_library")

def elm_grpc_library(name, protos, plugin_opts = [], elm_proto_compile_kwargs = {}, **kwargs):
    generic_elm_proto_library(
        name = name,
        protos = protos,
        plugin_opts = plugin_opts + [ "grpc=true" ],
        elm_proto_compile_kwargs = elm_proto_compile_kwargs,
        **kwargs,
    )
    
