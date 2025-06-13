load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "83e5af4d17385d1c3268c31ae217dbfc8525aa7bcf52508dc6864baffc8b9501",
            strip_prefix = "rules_js-2.3.7",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.3.7/rules_js-v2.3.7.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "9f9f3b300a9264e4c77999312ce663be5dee9a56e361a1f6fe7ec60e1beef9a3",
            strip_prefix = "rules_python-1.4.1",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.4.1/rules_python-1.4.1.tar.gz",
        )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "c3a0a9ece8932e31c3b736e2db18b1c42e7070cd9b881388b26d01aa71e24ca2",
            strip_prefix = "protobuf-31.1",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v31.1.tar.gz",
            ],
        )

    if not native.existing_rule("rules_java"):
        http_archive(
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/8.6.1/rules_java-8.6.1.tar.gz",
            ],
            sha256 = "c5bc17e17bb62290b1fd8fdd847a2396d3459f337a7e07da7769b869b488ec26",
        )

    if not native.existing_rule("rules_shell"):
        http_archive(
            name = "rules_shell",
            sha256 = "b15cc2e698a3c553d773ff4af35eb4b3ce2983c319163707dddd9e70faaa062d",
            strip_prefix = "rules_shell-0.5.0",
            url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.5.0/rules_shell-v0.5.0.tar.gz",
        )
