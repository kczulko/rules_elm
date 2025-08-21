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
            sha256 = "0a1cefefb4a7b550fb0b43f54df67d6da95b7ba352637669e46c987f69986f6a",
            strip_prefix = "rules_python-1.5.3",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.5.3/rules_python-1.5.3.tar.gz",
        )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "3ad017543e502ffaa9cd1f4bd4fe96cf117ce7175970f191705fa0518aff80cd",
            strip_prefix = "protobuf-32.0",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v32.0.tar.gz",
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
            sha256 = "fce2a7a974aa70e9367068122e19c39a6a27a5aca30698bcf9030beb529612b6",
            strip_prefix = "rules_shell-0.6.0",
            url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.6.0/rules_shell-v0.6.0.tar.gz",
        )
