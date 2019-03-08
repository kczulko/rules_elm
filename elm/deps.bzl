load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")

def elm_register_toolchains():
    _http_archive(
        name = "com_github_elm_compiler_linux",
        build_file_content = """exports_files(["elm"])""",
        sha256 = "7a82bbf34955960d9806417f300e7b2f8d426933c09863797fe83b67063e0139",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-linux.tar.gz"],
    )

    _http_archive(
        name = "com_github_elm_compiler_mac",
        build_file_content = """exports_files(["elm"])""",
        sha256 = "18410e605208fc2b620f5e30bccbbd122c992a27de46f9f362271ce3dcc66962",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.0/binaries-for-mac.tar.gz"],
    )

    native.register_toolchains("@com_github_edschouten_rules_elm//elm/toolchain:linux")
    native.register_toolchains("@com_github_edschouten_rules_elm//elm/toolchain:mac")
