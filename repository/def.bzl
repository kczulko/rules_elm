def _elm_repository_impl(ctx):
    ctx.download_and_extract(
        url = ctx.attr.urls,
        sha256 = ctx.attr.sha256,
        type = ctx.attr.type,
        stripPrefix = ctx.attr.strip_prefix,
    )

    result = ctx.execute([
        "python3",
        ctx.path(Label("@com_github_edschouten_rules_elm//repository:generate_build_files.py")),
    ])
    if result.return_code:
        fail("failed to generate BUILD files for %s: %s" % (ctx.name, result.stderr))

elm_repository = repository_rule(
    attrs = {
        "urls": attr.string_list(),
        "strip_prefix": attr.string(),
        "type": attr.string(),
        "sha256": attr.string(),
    },
    implementation = _elm_repository_impl,
)
