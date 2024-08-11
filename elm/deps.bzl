load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive", _http_file = "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@aspect_rules_js//npm:repositories.bzl", "npm_translate_lock")
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")
load("@aspect_rules_js//js:toolchains.bzl", "DEFAULT_NODE_VERSION", "rules_js_register_toolchains")

def http_archive(**kwargs):
    maybe(_http_archive, **kwargs)

def http_file(**kwargs):
    maybe(_http_file, **kwargs)

def elm_register_toolchains(register = True):
    rules_js_dependencies()
    
    http_file(
        name = "com_github_elm_compiler_linux_x86_64",
        sha256 = "e44af52bb27f725a973478e589d990a6428e115fe1bb14f03833134d6c0f155c",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz"],
    )

    http_file(
        name = "com_github_elm_compiler_oxs_x86_64",
        sha256 = "05289f0e3d4f30033487c05e689964c3bb17c0c48012510dbef1df43868545d1",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-mac-64-bit.gz"],
    )
    http_file(
        name = "com_github_elm_compiler_osx_arm64",
        sha256 = "552c8300b55dafdf52073b095e7bc6afc1b2ea2a600fbc7654bca8a241e38689",
        urls = ["https://github.com/elm/compiler/releases/download/0.19.1/binary-for-mac-64-bit-ARM.gz"],
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

    if register:
        rules_js_register_toolchains(node_version = DEFAULT_NODE_VERSION)
        
        platforms = [ 'linux_x86_64', 'osx_x86_64', 'osx_arm64' ]
        for platform in platforms:
           native.register_toolchains("@com_github_edschouten_rules_elm//elm/toolchain:%s" % platform)

        npm_translate_lock(
            name = "com_github_edschouten_rules_elm_npm",
            pnpm_lock = "@com_github_edschouten_rules_elm//tools/npm:pnpm-lock.yaml",
            verify_node_modules_ignored = "@com_github_edschouten_rules_elm//:.bazelignore",
        )

