# file generated by rules_elm
load("@rules_elm//elm:defs.bzl", "elm_package")

elm_package(
    name = {{name}},
    srcs = [
        "elm.json",
    ] + glob(
      include = [
        "**/*.elm",
        "**/*.js",
      ],
      allow_empty = True,
    ),
    deps = {{deps}},
    package_name = {{package_name}},
    package_version = {{package_version}},
    visibility = ["//visibility:public"],
)