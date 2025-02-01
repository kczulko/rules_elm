load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "875b8d01af629dbf626eddc5cf239c9f0da20330f4d99ad956afc961096448dd",
            strip_prefix = "rules_js-2.1.3",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.1.3/rules_js-v2.1.3.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "690e0141724abb568267e003c7b6d9a54925df40c275a870a4d934161dc9dd53",
            strip_prefix = "rules_python-0.40.0",
            url = "https://github.com/bazelbuild/rules_python/releases/download/0.40.0/rules_python-0.40.0.tar.gz",
        )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "ce5d00b78450a0ca400bf360ac00c0d599cc225f049d986a27e9a4e396c5a84a",
            strip_prefix = "protobuf-29.0-rc2",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v29.0-rc2.tar.gz",
            ],
        )

    if not native.existing_rule("rules_java"):
        http_archive(
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/8.8.0/rules_java-8.8.0.tar.gz",
            ],
            sha256 = "f79a6e10cdd213ceded45884914bb8c68f0c8d41144e74ec89ebb74984c409ac",
        )

    if not native.existing_rule("rules_shell"):
        http_archive(
            name = "rules_shell",
            sha256 = "410e8ff32e018b9efd2743507e7595c26e2628567c42224411ff533b57d27c28",
            strip_prefix = "rules_shell-0.2.0",
            url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.2.0/rules_shell-v0.2.0.tar.gz",
        )
