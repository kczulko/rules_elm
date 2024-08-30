load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive", _http_file = "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@aspect_rules_js//npm:repositories.bzl", "npm_translate_lock")
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")
load("@aspect_rules_js//js:toolchains.bzl", "DEFAULT_NODE_VERSION", "rules_js_register_toolchains")
load("@com_github_edschouten_rules_elm//elm/private:elm_toolchain_repo.bzl", "elm_toolchains_repo", "elm_compiler_repositories", "PLATFORMS")

def http_archive(**kwargs):
    maybe(_http_archive, **kwargs)

def http_file(**kwargs):
    maybe(_http_file, **kwargs)

def elm_register_toolchains(register = True):
    rules_js_dependencies()

    http_archive(
        name = "com_github_rtfeldman_node_test_runner",
        build_file_content = """load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_library")
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

    elm_compilers_toolchain_repo_name = "elm_compiler_toolchains"

    for platform in PLATFORMS:
        elm_compiler_repositories(
            name = "elm_{platform}".format(platform = platform),
            platform = platform
        )

        if register:
            native.register_toolchains("@{}//:{}_toolchain".format(elm_compilers_toolchain_repo_name, platform))

    elm_toolchains_repo(
        name = elm_compilers_toolchain_repo_name,
        toolchain = "@elm_{platform}//:elm_toolchain_info",
    )

    if register:
        rules_js_register_toolchains(node_version = DEFAULT_NODE_VERSION)

        npm_translate_lock(
            name = "com_github_edschouten_rules_elm_npm",
            pnpm_lock = "@com_github_edschouten_rules_elm//tools/npm:pnpm-lock.yaml",
            verify_node_modules_ignored = "@com_github_edschouten_rules_elm//:.bazelignore",
        )

