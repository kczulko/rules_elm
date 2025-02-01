#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
VERSION=${TAG:1}
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_elm-$VERSION"
ARCHIVE="$PREFIX.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat << EOF
## Using bzlmod with Bazel 6 or later:

1. Add \`common --enable_bzlmod\` to \`.bazelrc\`.

2. Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "rules_elm", version = "${TAG:1}")

# Declare external elm dependencies, for example:
elm = use_extension("@rules_elm//elm:extensions.bzl", "elm")
elm.repository(
    name = "elm_package_elm_core",
    sha256 = "6e37b11c88c89a68d19d0c7625f1ef39ed70c59e443def95e4de98d6748c80a7",
    strip_prefix = "core-1.0.5",
    urls = ["https://github.com/elm/core/archive/1.0.5.tar.gz"],
)
use_repo(elm, "elm_package_elm_core")

\`\`\`

## Using WORKSPACE:

\`\`\`starlark

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_elm",
    sha256 = "${SHA}",
    strip_prefix = "${PREFIX}",
    urls = "https://github.com/kczulko/rules_elm/releases/download/${TAG}/${ARCHIVE}",
)

load("@rules_elm//elm:dependencies.bzl", "elm_dependencies")
elm_dependencies()
load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")
rules_java_dependencies()
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
protobuf_deps()
load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")
rules_js_dependencies()
load("@rules_python//python:repositories.bzl", "py_repositories")
py_repositories()

load("@rules_shell//shell:repositories.bzl", "rules_shell_toolchains")
rules_shell_toolchains()
load("@rules_elm//elm:repositories.bzl", "elm_register_toolchains")
elm_register_toolchains()
load("@rules_elm_npm//:repositories.bzl", elm_npm_repositories = "npm_repositories")
elm_npm_repositories()

EOF

# awk 'f;/--SNIP--/{f=1}' e2e/workspace/WORKSPACE.bazel
echo "\`\`\`"
