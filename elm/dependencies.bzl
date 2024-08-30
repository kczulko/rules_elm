load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@aspect_rules_js//js:repositories.bzl", "rules_js_dependencies")

def http_archive(**kwargs):
    maybe(_http_archive, **kwargs)

# TODO: add all non bzlmod deps here!
def elm_dependencies():
    rules_js_dependencies()
