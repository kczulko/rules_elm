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
            sha256 = "14a225870ab4e91869652cfd69ef2028277fc1dc4910d65d353b62d6e0ae21f4",
            strip_prefix = "rules_proto-7.1.0",
            url = "https://github.com/bazelbuild/rules_proto/releases/download/7.1.0/rules_proto-7.1.0.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "be04b635c7be4604be1ef20542e9870af3c49778ce841ee2d92fcb42f9d9516a",
            strip_prefix = "rules_python-0.35.0",
            url = "https://github.com/bazelbuild/rules_python/releases/download/0.35.0/rules_python-0.35.0.tar.gz",
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


