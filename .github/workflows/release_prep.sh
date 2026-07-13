#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=$1
VERSION=${TAG:1}
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="rules_elm-${TAG:1}"
ARCHIVE="rules_elm-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip > $ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

# Add generated API docs to the release, see https://github.com/bazelbuild/bazel-central-registry/issues/5593
docs="$(mktemp -d)"; targets="$(mktemp)"
bazel --output_base="$docs" query --output=label --output_file="$targets" 'kind("starlark_doc_extract rule", //...)'
bazel --output_base="$docs" build --target_pattern_file="$targets"
tar --create --auto-compress \
    --directory "$(bazel --output_base="$docs" info bazel-bin)" \
    --file "$GITHUB_WORKSPACE/${ARCHIVE%.tar.gz}.docs.tar.gz" .

cat << EOF
## Using bzlmod:

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
