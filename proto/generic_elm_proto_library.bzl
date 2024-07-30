load("@com_github_edschouten_rules_elm//proto:elm_proto_compile.bzl", "elm_proto_compile")

load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_library")

def generic_elm_proto_library(name, protos, plugin_opts = [], elm_proto_compile_kwargs = {}, **kwargs):
    elm_proto_compile_name = "{}_elm_proto_compile".format(name)
    elm_library_name = "{}_elm_library".format(name)

    elm_proto_compile(
        name = elm_proto_compile_name,
        protos = protos,
        options = {
            "@com_github_edschouten_rules_elm//proto:protoc_gen_elm": plugin_opts,
        },
        **elm_proto_compile_kwargs,
    )

    elm_library(
        name = name,
        strip_import_prefix = elm_proto_compile_name,
        srcs = [ ":{}".format(elm_proto_compile_name) ],
        **kwargs,
    )
