load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "b71565da7a811964e30cccb405544d551561e4b56c65f0c0aeabe85638920bd6",
            strip_prefix = "rules_js-2.4.2",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.4.2/rules_js-v2.4.2.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "fa532d635f29c038a64c8062724af700c30cf6b31174dd4fac120bc561a1a560",
            strip_prefix = "rules_python-1.5.1",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.5.1/rules_python-1.5.1.tar.gz",
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
