load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive", _http_file = "http_file")

def elm_register_toolchains():
    _http_file(
        name = "com_github_elm_compiler_linux",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz"]
    )

    _http_file(
        name = "com_github_elm_compiler_mac",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-mac-64-bit.gz"]
    )

    _http_archive(
        name = "com_github_rtfeldman_node_test_runner",
        build_file_content = """load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_library")

elm_library(
    name = "node_test_runner",
    srcs = glob(["src/**/*.elm"]),
    strip_import_prefix = "src",
    visibility = ["//visibility:public"],
)""",
        sha256 = "0a674bc62347b8476a4d54e432a65f49862278a9062fd86948dfafafb96c511d",
        strip_prefix = "node-test-runner-0.19.1-revision2",
        urls = ["https://github.com/rtfeldman/node-test-runner/archive/0.19.1-revision2.tar.gz"],
    )

    native.register_toolchains("@com_github_edschouten_rules_elm//elm/toolchain:linux")
    native.register_toolchains("@com_github_edschouten_rules_elm//elm/toolchain:mac")
