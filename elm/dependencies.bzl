load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "1be1a3ec3d3baec4a71bc09ce446eb59bb48ae31af63016481df1532a0d81aee",
            strip_prefix = "rules_js-2.3.5",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.3.5/rules_js-v2.3.5.tar.gz",
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
            sha256 = "2b695cb1eaef8e173f884235ee6d55f57186e95d89ebb31361ee55cb5fd1b996",
            strip_prefix = "protobuf-31.0",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v31.0.tar.gz",
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
            sha256 = "bc61ef94facc78e20a645726f64756e5e285a045037c7a61f65af2941f4c25e1",
            strip_prefix = "rules_shell-0.4.1",
            url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.4.1/rules_shell-v0.4.1.tar.gz",
        )
