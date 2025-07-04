load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "304c51726b727d53277dd28fcda1b8e43b7e46818530b8d6265e7be98d5e2b25",
            strip_prefix = "rules_js-2.3.8",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.3.8/rules_js-v2.3.8.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "7b9039c31e909cf59eeaea8ccbdc54f09f7ebaeb9609b94371c7de45e802977c",
            strip_prefix = "rules_python-1.5.0",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.5.0/rules_python-1.5.0.tar.gz",
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
