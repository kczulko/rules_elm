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
            sha256 = "f2e80f97f9c0b82e2489e61e725df1e6bdaf16c4dacf5e26b95668787164baff",
            strip_prefix = "rules_python-1.6.1",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.6.1/rules_python-1.6.1.tar.gz",
        )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "d2081ab9528292f7980ef2d88d2be472453eea4222141046ad4f660874d5f24e",
            strip_prefix = "protobuf-32.1",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v32.1.tar.gz",
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
            sha256 = "e6b87c89bd0b27039e3af2c5da01147452f240f75d505f5b6880874f31036307",
            strip_prefix = "rules_shell-0.6.1",
            url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.6.1/rules_shell-v0.6.1.tar.gz",
        )
