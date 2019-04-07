from __future__ import print_function

import json
import sys

with open("elm.json") as f:
    metadata = json.load(f)

deps = sorted(
    "@elm_package_" + name.replace("/", "_").replace("-", "_")
    for name in metadata["dependencies"].keys()
)

with open("BUILD.bazel", "w") as build_file:
    name = metadata["name"]
    if name.startswith("elm/") or name.startswith("elm-explorations/"):
        # For official elm/* and elm-explorations/* packages, generate a
        # true elm_package(). These packages tend to rely on features
        # that are not exposed publicly (e.g., Elm.Kernel.*).
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
                "name": json.dumps(sys.argv[1]),
                "deps": json.dumps(deps),
                "package_name": json.dumps(metadata["name"]),
                "package_version": json.dumps(metadata["version"]),
            },
            file=build_file,
        )
    else:
        # For other libraries, simply emit an elm_library(). This is
        # more useful in our case, as 'elm make' doesn't return sensible
        # errors about incorrect dependencies (e.g., version mismatches)
        # in our case. By declaring a library, we disable package
        # version checking entirely.
        print(
            """load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_library")

elm_library(
    name = %(name)s,
    srcs = glob(["src/**/*.elm"]),
    deps = %(deps)s,
    strip_import_prefix = "src",
    visibility = ["//visibility:public"],
)"""
            % {"name": json.dumps(sys.argv[1]), "deps": json.dumps(deps)},
            file=build_file,
        )
