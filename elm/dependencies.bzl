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

    if not native.existing_rule("rules_proto"):
        http_archive(
            name = "rules_proto",
            sha256 = "6fb6767d1bef535310547e03247f7518b03487740c11b6c6adb7952033fe1295",
            strip_prefix = "rules_proto-6.0.2",
            url = "https://github.com/bazelbuild/rules_proto/releases/download/6.0.2/rules_proto-6.0.2.tar.gz",
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
            sha256 = "79cc6d09d02706c5a73e900ea842b5b3dae160f371b6654774947fe781851423",
            strip_prefix = "protobuf-27.5",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v27.5.tar.gz",
            ],
        )


