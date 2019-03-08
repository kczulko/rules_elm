import json
import os
import sys

with open("elm.json") as f:
    metadata = json.load(f)

for root, dirs, files in os.walk("src"):
    with open(os.path.join(root, "BUILD.bazel"), "w") as build_file:
        print(
            """
load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_library")
""",
            file=build_file,
        )

        for filename in files:
            # TODO(edsch): Respect exposed-modules.
            if filename.endswith(".elm"):
                print(
                    """
elm_library(
    name = %(name)s,
    srcs = %(srcs)s,
    deps = %(deps)s,
    visibility = ["//visibility:public"],
)"""
                    % {
                        "name": repr(filename[: -len(".elm")]),
                        "srcs": repr([filename]),
                        "deps": repr([]),
                    },
                    file=build_file,
                )
