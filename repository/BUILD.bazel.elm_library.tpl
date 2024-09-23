# file generated by rules_elm
load("@rules_elm//elm:defs.bzl", "elm_library")

elm_library(
    name = {{name}},
    srcs = glob(["src/**/*.elm"]),
    deps = {{deps}},
    strip_import_prefix = "src",
    visibility = ["//visibility:public"],
)