load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive", _http_file = "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(**kwargs):
    maybe(_http_archive, **kwargs)

def http_file(**kwargs):
    maybe(_http_file, **kwargs)

def elm_register_toolchains(register = True):
    http_file(
        name = "com_github_elm_compiler_linux_x86",
        sha256 = "e44af52bb27f725a973478e589d990a6428e115fe1bb14f03833134d6c0f155c",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz"],
    )

    http_file(
        name = "com_github_elm_compiler_mac_x86",
        sha256 = "18410e605208fc2b620f5e30bccbbd122c992a27de46f9f362271ce3dcc66962",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-mac-64-bit.tar.gz"],
    )
    http_file(
        name = "com_github_elm_compiler_mac_arm64",
        sha256 = "18410e605208fc2b620f5e30bccbbd122c992a27de46f9f362271ce3dcc66962",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-mac-64-bit-ARM.tar.gz"],
    )

    http_archive(
        name = "com_github_rtfeldman_node_test_runner",
        build_file_content = """load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_library")
exports_files(["lib/Parser.js"])

elm_library(
    name = "node_test_runner",
    srcs = glob(["elm/src/**/*.elm"]),
    strip_import_prefix = "elm/src",
    visibility = ["//visibility:public"],
)""",
        sha256 = "03d4f0950527599ebe2be4d8d8abc9c8638d93abe5e667d5d3427fcecc6dc24d",
        strip_prefix = "node-test-runner-0.19.1-revision12",
        urls = ["https://github.com/rtfeldman/node-test-runner/archive/0.19.1-revision12.tar.gz"],
    )

    http_archive(
        name = "com_github_tiziano88_elm_protobuf_linux",
        build_file_content = """exports_files(glob(["**/*"]))""",
        sha256 = "d096775821b26c6e29542d096159d7dca942f54d51eecd2ca3897b7cb6da685e",
        urls = [
            "https://github.com/tiziano88/elm-protobuf/releases/download/3.0.0/elm-protobuf-3.0.0-linux-x86_64.tar.gz",
        ],
    )
    http_archive(
        name = "com_github_tiziano88_elm_protobuf_mac",
        build_file_content = """exports_files(glob(["**/*"]))""",
        sha256 = "d096775821b26c6e29542d096159d7dca942f54d51eecd2ca3897b7cb6da685e",
        urls = [
            "https://github.com/tiziano88/elm-protobuf/releases/download/3.0.0/elm-protobuf-3.0.0-osx-x86_64.tar.gz",
        ],
    )

    if register:
        platforms = [ 'linux_x86', 'mac_x86', 'mac_arm64' ]
        for platform in platforms:
           native.register_toolchains("@com_github_edschouten_rules_elm//elm/toolchain:%s" % platform)
        # native.register_toolchains("@com_github_edschouten_rules_elm//proto/toolchain:linux")
        # native.register_toolchains("@com_github_edschouten_rules_elm//proto/toolchain:osx")

