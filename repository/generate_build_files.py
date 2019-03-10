import json
import sys

with open("elm.json") as f:
    metadata = json.load(f)

deps = sorted(
    "@elm_package_" + name.replace("/", "_").replace("-", "_")
    for name in metadata["dependencies"].keys()
)

with open("BUILD.bazel", "w") as build_file:
    print(
        """load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_package")

elm_package(
    name = %(name)s,
    srcs = [
        "elm.json",
    ] + glob([
        "**/*.elm",
        "**/*.js",
    ]),
    deps = %(deps)s,
    package_name = %(package_name)s,
    package_version = %(package_version)s,
    visibility = ["//visibility:public"],
)"""
        % {
            "name": repr(sys.argv[1]),
            "deps": repr(deps),
            "package_name": repr(metadata["name"]),
            "package_version": repr(metadata["version"]),
        },
        file=build_file,
    )
