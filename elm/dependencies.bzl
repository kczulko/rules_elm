load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def elm_dependencies():
    if not native.existing_rule("aspect_rules_js"):
        http_archive(
            name = "aspect_rules_js",
            sha256 = "1be1a3ec3d3baec4a71bc09ce446eb59bb48ae31af63016481df1532a0d81aee",
            strip_prefix = "rules_js-2.3.5",
            url = "https://github.com/aspect-build/rules_js/releases/download/v2.3.5/rules_js-v2.3.5.tar.gz",
        )

    if not native.existing_rule("rules_python"):
        http_archive(
            name = "rules_python",
            sha256 = "2cc26bbd53854ceb76dd42a834b1002cd4ba7f8df35440cf03482e045affc244",
            strip_prefix = "rules_python-1.3.0",
            url = "https://github.com/bazelbuild/rules_python/releases/download/1.3.0/rules_python-1.3.0.tar.gz",
        )

    if not native.existing_rule("com_google_protobuf"):
        http_archive(
            name = "com_google_protobuf",
            sha256 = "07a43d88fe5a38e434c7f94129cad56a4c43a51f99336074d0799c2f7d4e44c5",
            strip_prefix = "protobuf-30.2",
            urls = [
                "https://github.com/protocolbuffers/protobuf/archive/v30.2.tar.gz",
            ],
        )

    if not native.existing_rule("rules_java"):
        http_archive(
            name = "rules_java",
            urls = [
                "https://github.com/bazelbuild/rules_java/releases/download/8.6.1/rules_java-8.6.1.tar.gz",
            ],
            sha256 = "c5bc17e17bb62290b1fd8fdd847a2396d3459f337a7e07da7769b869b488ec26",
        )

    if not native.existing_rule("rules_shell"):
        http_archive(
            name = "rules_shell",
            sha256 = "410e8ff32e018b9efd2743507e7595c26e2628567c42224411ff533b57d27c28",
            strip_prefix = "rules_shell-0.2.0",
            url = "https://github.com/bazelbuild/rules_shell/releases/download/v0.2.0/rules_shell-v0.2.0.tar.gz",
        )
