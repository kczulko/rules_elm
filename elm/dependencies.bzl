load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "17c5964f6a4507488c2ce99ebd493ee111da5d5cab85ca99119eaae331d38989",
            strip_prefix = "rules_js-2.5.0",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.5.0/rules_js-v2.5.0.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "13671d304cfe43350302213a60d93a5fc0b763b0a6de17397e3e239253b61b73",
            strip_prefix = "rules_python-1.5.4",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.5.4/rules_python-1.5.4.tar.gz",
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
