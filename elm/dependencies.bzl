load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "6e4637a63acbd2ca080f463cb18fc0d7439f2401adbfe0028f3f4544c9eb8085",
            strip_prefix = "rules_js-2.8.1",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.8.1/rules_js-v2.8.1.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "2f5c284fbb4e86045c2632d3573fc006facbca5d1fa02976e89dc0cd5488b590",
            strip_prefix = "rules_python-1.6.3",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.6.3/rules_python-1.6.3.tar.gz",
        )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "0c98bb704ceb4e68c92f93907951ca3c36130bc73f87264e8c0771a80362ac97",
            strip_prefix = "protobuf-33.1",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v33.1.tar.gz",
            ],
        )

    if not native.existing_rule("rules_java"):
        http_archive(
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/8.16.1/rules_java-8.16.1.tar.gz",
            ],
            sha256 = "1b30698d89dccd9dc01b1a4ad7e9e5c6e669cdf1918dbb050334e365b40a1b5e",
        )

    if not native.existing_rule("rules_shell"):
        http_archive(
            name = "rules_shell",
            sha256 = "e6b87c89bd0b27039e3af2c5da01147452f240f75d505f5b6880874f31036307",
            strip_prefix = "rules_shell-0.6.1",
            url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.6.1/rules_shell-v0.6.1.tar.gz",
        )
