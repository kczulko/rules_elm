load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive", _http_file = "http_file")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@aspect_rules_js//npm:repositories.bzl", "npm_translate_lock")
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")
load("@aspect_rules_js//js:toolchains.bzl", "DEFAULT_NODE_VERSION", "rules_js_register_toolchains")

def http_archive(**kwargs):
    maybe(_http_archive, **kwargs)

SUPPORTED_ELM_VERSION = "0.19.1"

ELM_VERSIONS = {
    SUPPORTED_ELM_VERSION: {
        "x86_64-linux": {
            "sha256": "e44af52bb27f725a973478e589d990a6428e115fe1bb14f03833134d6c0f155c",
            "url": "https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz",
        },
        "x86_64-darwin": {
            "sha256": "05289f0e3d4f30033487c05e689964c3bb17c0c48012510dbef1df43868545d1",
            "url": "https://github.com/elm/compiler/releases/download/0.19.1/binary-for-mac-64-bit.gz",
        },
        "aarch64-darwin": {
            "sha256": "552c8300b55dafdf52073b095e7bc6afc1b2ea2a600fbc7654bca8a241e38689",
            "url": "https://github.com/elm/compiler/releases/download/0.19.1/binary-for-mac-64-bit-ARM.gz",
        }
    }
}

PLATFORMS = {
    "x86_64-linux": struct(
        compatible_with = [
            "@platforms//os:linux",
            "@platforms//cpu:x86_64",
        ]
    ),
    "x86_64-darwin": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:x86_64",
        ]
    ),
    "aarch64-darwin": struct(
        compatible_with = [
            "@platforms//os:macos",
            "@platforms//cpu:aarch64",
        ]
    )
}

def _elm_compiler_repo_impl(repository_ctx):
    platform = repository_ctx.attr.platform
    elm_version = ELM_VERSIONS[repository_ctx.attr._elm_version]
    compatible_with = PLATFORMS[platform].compatible_with
    url = elm_version[platform]["url"]
    sha256 = elm_version[platform]["sha256"]
    repository_ctx.download(
        url = url,
        sha256 = sha256,
        output = "compiler.gz",
    )

    BUILD_TMPL = """
# file generated by repositories.bzl of @rules_elm
load("@rules_elm//elm/private:elm_toolchain.bzl", "elm_toolchain")

genrule(
    name = "extract_elm_compiler",
    srcs = [":compiler.gz"],
    outs = [ "compiler" ],
    cmd = "gunzip -c $(SRCS) > $@ && chmod +x $@"
)

elm_toolchain(
    name = "elm_toolchain_info",
    elm = ":extract_elm_compiler",
    visibility = ["//visibility:public"],
)"""

    repository_ctx.file(
        "BUILD.bazel",
        content = BUILD_TMPL.format(
            platform = platform,
            compatible_with = compatible_with,
        ),
    )

def _elm_toolchains_repo_impl(repository_ctx):

    TOOLCHAIN_TMPL = """
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = {compatible_with},
    toolchain = "{toolchain}",
    toolchain_type = "@rules_elm//elm:toolchain",
)
"""
    build_content = """
# file generated by repositories.bzl of @rules_elm

"""

    toolchain = repository_ctx.attr.toolchain

    for platform in PLATFORMS:
        compatible_with = PLATFORMS[platform].compatible_with
        build_content += TOOLCHAIN_TMPL.format(
            platform = platform,
            compatible_with = compatible_with,
            toolchain = toolchain.format(platform = platform)
        )

    repository_ctx.file("BUILD.bazel", content = build_content)

elm_toolchains_repository = repository_rule(
    _elm_toolchains_repo_impl,
    doc = "All default elm toolchains",
    attrs = {
        "toolchain": attr.string(doc = "Label of the toolchain with {platform} left as placeholder. example; @elm_{platform}//:crane_toolchain"),
        "_elm_version": attr.string(default = SUPPORTED_ELM_VERSION),
    }
)

elm_compiler_repository = repository_rule(
    _elm_compiler_repo_impl,
    doc = "Fetching external elm compiler",
    attrs = {
        "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
        "_elm_version": attr.string(default = SUPPORTED_ELM_VERSION),
    }
)

def elm_register_toolchains(register = True):

    http_archive(
        name = "com_github_rtfeldman_node_test_runner",
        build_file_content = """load("@rules_elm//elm:def.bzl", "elm_library")
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
        elm_compiler_repository(
            name = "elm_{platform}".format(platform = platform),
            platform = platform
        )

        if register:
            native.register_toolchains("@{}//:{}_toolchain".format(elm_compilers_toolchain_repo_name, platform))

    elm_toolchains_repository(
        name = elm_compilers_toolchain_repo_name,
        toolchain = "@elm_{platform}//:elm_toolchain_info",
    )

    if register:
        rules_js_register_toolchains(node_version = DEFAULT_NODE_VERSION)

        npm_translate_lock(
            name = "rules_elm_npm",
            pnpm_lock = "@rules_elm//tools/npm:pnpm-lock.yaml",
            verify_node_modules_ignored = "@rules_elm//:.bazelignore",
        )
