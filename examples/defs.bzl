load(
    "@rules_bazel_integration_test//bazel_integration_test:defs.bzl",
    "bazel_integration_test",
    "bazel_integration_tests",
    "integration_test_utils",
)

_configs = ["bzlmod", "nobzlmod"]

def mkBazelRcPrefix(bzl_version):
    return "bazel{}".format(bzl_version[0])

def gen_name(name_prefix, bazel_binary_name, config):
    return "{}_{}_{}".format(name_prefix, bazel_binary_name, config)


def gen_test_names(name_prefix, bazel_binaries, config):
    return [
        gen_name(name_prefix, bazel_binary_name, config)
        for bazel_binary_name in bazel_binaries
    ]

def gen_test_names_each(name_prefixes, bazel_binaries):
    result = []
    for name_prefix in name_prefixes:
        for config in _configs:
            result += gen_test_names(name_prefix, bazel_binaries, config)

    return result

def rules_elm_integration_test(
    name,
    workspace_path,
    bazel_cmd,
    expected_output,
    test_runner,
    **kwargs,
):
    bazel_integration_test(
        name = name,
        test_runner = test_runner,
        workspace_path = workspace_path,
        workspace_files = integration_test_utils.glob_workspace_files(workspace_path) + [
            "@rules_elm//:local_repository_files"
        ],
        env = {
            "BAZEL_CMD": bazel_cmd,
            "EXPECTED_OUTPUT": expected_output,
        },
        **kwargs,
    )

def rules_elm_integration_test_each_bazel(
    name,
    bazel_binaries,
    workspace_path,
    bazel_cmd,
    expected_output,
    test_runner = ":output_match_runner",
    **kwargs,
):
    for config in _configs:
        for bzl_version, bzl_label in bazel_binaries:
            rules_elm_integration_test(
                name = gen_name(name, bzl_version, config),
                workspace_path = workspace_path,
                bazel_cmd = bazel_cmd + " --config={}_{}".format(mkBazelRcPrefix(bzl_version), config),
                expected_output = expected_output,
                test_runner = test_runner,
                bazel_binary = bzl_label,
                tags = [
                    bzl_version,
                    # for bazel7 sandboxing issue
                    # https://github.com/bazelbuild/bazel/issues/1990
                    "no-sandbox",
                ],
                **kwargs,
            )
