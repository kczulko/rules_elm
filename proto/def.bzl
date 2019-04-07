load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

_WELL_KNOWN_PROTOS = ["google/protobuf/timestamp.proto"]

def _convert_proto_to_elm_path(path):
    return "/".join([component.capitalize() for component in path.split("/")])

def _elm_proto_library_aspect_impl(target, ctx):
    args = ctx.actions.args()
    proto = target[ProtoInfo]
    elm_srcs = []
    outpath = None
    for src in proto.direct_sources:
        # Add command line flag for input file.
        base_path = src.path
        if src.root.path != "":
            base_path = base_path[len(src.root.path) + 1:]
        base_path = base_path[len(src.owner.workspace_root) + 1:]
        if base_path in _WELL_KNOWN_PROTOS:
            continue
        args.add_all([base_path])

        # Declare output file. Elm uses capitalized package names.
        output_path = "/".join([
            component.capitalize()
            for component in base_path.split("/")
        ])[:-6] + ".elm"
        out = ctx.actions.declare_file(output_path)
        elm_srcs.append(out)

        # Determine the base output directory for --elm_out.
        if outpath == None:
            outpath = out.root.path + "/" + ctx.label.workspace_root + "/" + ctx.label.package

    if elm_srcs:
        # Invoke the compiler, as one or more source files were provided
        # that actually need building.
        args.add_all([
            "--plugin",
            ctx.executable._plugin.path,
            "--elm_out",
            outpath,
        ])
        args.add_all(proto.transitive_proto_path, before_each = "-I")

        # TODO(edsch): This should be removed once this is resolved:
        # https://github.com/bazelbuild/bazel/issues/7964
        args.add_all([
            "bazel-out/k8-fastbuild/genfiles/" + p
            for p in proto.transitive_proto_path.to_list()
        ], before_each = "-I")
        ctx.actions.run(
            executable = ctx.executable._protoc,
            arguments = [args],
            inputs = proto.transitive_sources + [ctx.executable._plugin],
            outputs = elm_srcs,
        )
        return [
            _create_elm_library_provider(
                ctx.rule.attr.deps + [ctx.attr._protobuf_library],
                [],
                [],
                [outpath],
                elm_srcs,
            ),
        ]
    else:
        # No source files to build, as all of them correspond with
        # built-in types.
        return [
            _create_elm_library_provider([], [], [], [], []),
        ]

_elm_proto_library_aspect = aspect(
    _elm_proto_library_aspect_impl,
    attr_aspects = ["deps"],
    attrs = {
        "_protoc": attr.label(
            allow_files = True,
            single_file = True,
            executable = True,
            cfg = "host",
            default = Label("@com_google_protobuf//:protoc"),
        ),
        "_plugin": attr.label(
            allow_files = True,
            single_file = True,
            executable = True,
            cfg = "host",
            default = Label("@com_github_tiziano88_elm_protobuf//protoc-gen-elm"),
        ),
        "_protobuf_library": attr.label(
            default = Label("@elm_package_tiziano88_elm_protobuf"),
        ),
    },
)

def _elm_proto_library_impl(ctx):
    return ctx.attr.proto[_ElmLibrary]

elm_proto_library = rule(
    _elm_proto_library_impl,
    attrs = {
        "proto": attr.label(
            aspects = [_elm_proto_library_aspect],
            mandatory = True,
            providers = ["proto"],
        ),
    },
)
