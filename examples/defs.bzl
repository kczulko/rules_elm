load(
    "@contrib_rules_bazel_integration_test//bazel_integration_test:defs.bzl",
    "bazel_integration_test",
    "integration_test_utils",
)

def gen_name(name_prefix, bazel_version):
    return "{}_{}".format(name_prefix, bazel_version)

def gen_test_names(name_prefix, bazel_versions):
    return [
        gen_name(name_prefix, bazel_version)
        for bazel_version in bazel_versions
    ]

def gen_test_names_each(name_prefixes, bazel_versions):
    result = []
    for name_prefix in name_prefixes:
      result += gen_test_names(name_prefix, bazel_versions)
    return result

def rules_elm_integration_test(
    name,
    bazel_version,
    workspace_path,
    bazel_cmd,
    expected_output,
    test_runner = ":output_match_runner"
):
    bazel_integration_test(
        name = gen_name(name, bazel_version),
        bazel_binary = "@{}//:bin/bazel".format(bazel_version),
        test_runner = test_runner,
        workspace_path = workspace_path,
        workspace_files = integration_test_utils.glob_workspace_files(workspace_path) + [
            "@com_github_edschouten_rules_elm//:local_repository_files"
        ],
        env = {
            "BAZEL_CMD": bazel_cmd,
            "EXPECTED_OUTPUT": expected_output,
        },
    )

def rules_elm_integration_test_each_bazel(
    name,
    bazel_versions,
    workspace_path,
    bazel_cmd,
    expected_output,
    test_runner = ":output_match_runner",
):
    for bazel_version in bazel_versions:
        rules_elm_integration_test(
            name = name,
            bazel_version = bazel_version,
            workspace_path = workspace_path,
            bazel_cmd = bazel_cmd,
            expected_output = expected_output,
            test_runner = test_runner,
        )
