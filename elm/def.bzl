ElmLibrary = provider()

def _elm_binary_impl(ctx):
    toolchain = ctx.toolchains["@com_github_edschouten_rules_elm//elm:toolchain"]
    package_directories = depset(transitive = [dep[ElmLibrary].package_directories for dep in ctx.attr.deps])
    source_directories = depset(transitive = [dep[ElmLibrary].source_directories for dep in ctx.attr.deps])
    dependencies = {}
    for dep in ctx.attr.deps:
        for name, version in dep[ElmLibrary].dependencies:
            dependencies[name] = version
    depset(transitive = [dep[ElmLibrary].dependencies for dep in ctx.attr.deps])
    deps_srcs = depset(transitive = [dep[ElmLibrary].transitive_srcs for dep in ctx.attr.deps])

    elm_json = ctx.actions.declare_file(ctx.attr.name + "-elm.json")
    ctx.actions.write(elm_json, """{
    "type": "application",
    "dependencies": {"direct": %s, "indirect": {}},
    "elm-version": "0.19.0",
    "source-directories": %s,
    "test-dependencies": {"direct": {}, "indirect": {}}
}""" % (
        repr(dependencies),
        repr(source_directories.to_list()),
    ))

    output = ctx.actions.declare_file(ctx.attr.name + ".js")
    ctx.actions.run(
        mnemonic = "Elm",
        executable = "python3",
        arguments = [
            ctx.files._compile[0].path,
            toolchain.elm.files.to_list()[0].path,
            elm_json.path,
            ctx.files.main[0].path,
            output.path,
        ] + package_directories.to_list(),
        inputs = toolchain.elm.files + ctx.files._compile + [elm_json] + ctx.files.main + deps_srcs,
        outputs = [output],
    )

    return [
        DefaultInfo(files = depset([output])),
    ]

elm_binary = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
        "_compile": attr.label(
            allow_files = True,
            single_file = True,
            default = Label("@com_github_edschouten_rules_elm//elm:compile.py"),
        ),
    },
    toolchains = ["@com_github_edschouten_rules_elm//elm:toolchain"],
    implementation = _elm_binary_impl,
)

def _elm_library_impl(ctx):
    source_directory = ctx.label.workspace_root
    if ctx.attr.strip_import_prefix:
        source_directory += "/" + ctx.attr.strip_import_prefix

    return [
        ElmLibrary(
            dependencies = depset(
                transitive = [dep[ElmLibrary].dependencies for dep in ctx.attr.deps],
            ),
            package_directories = depset(
                transitive = [dep[ElmLibrary].package_directories for dep in ctx.attr.deps],
            ),
            source_directories = depset(
                [source_directory],
                transitive = [dep[ElmLibrary].source_directories for dep in ctx.attr.deps],
            ),
            transitive_srcs = depset(
                ctx.files.srcs,
                transitive = [dep[ElmLibrary].transitive_srcs for dep in ctx.attr.deps],
            ),
        ),
    ]

elm_library = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
        "strip_import_prefix": attr.string(),
    },
    implementation = _elm_library_impl,
)

def _elm_package_impl(ctx):
    return [
        ElmLibrary(
            dependencies = depset(
                [(ctx.attr.package_name, ctx.attr.package_version)],
                transitive = [dep[ElmLibrary].dependencies for dep in ctx.attr.deps],
            ),
            package_directories = depset(
                [ctx.label.workspace_root + "/" + ctx.label.package],
                transitive = [dep[ElmLibrary].package_directories for dep in ctx.attr.deps],
            ),
            source_directories = depset(
                transitive = [dep[ElmLibrary].source_directories for dep in ctx.attr.deps],
            ),
            transitive_srcs = depset(
                ctx.files.srcs,
                transitive = [dep[ElmLibrary].transitive_srcs for dep in ctx.attr.deps],
            ),
        ),
    ]

elm_package = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "package_name": attr.string(mandatory = True),
        "package_version": attr.string(mandatory = True),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
    },
    implementation = _elm_package_impl,
)
