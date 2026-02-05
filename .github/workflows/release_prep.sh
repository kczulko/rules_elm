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
## Using Bazel 7 or later:

1. Add to your \`MODULE.bazel\` file:

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

EOF

# awk 'f;/--SNIP--/{f=1}' e2e/workspace/WORKSPACE.bazel
echo "\`\`\`"
