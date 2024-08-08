load("@bazel_skylib//lib:paths.bzl", "paths")
load(
    "//elm/private:providers.bzl",
    _ElmLibrary = "ElmLibrary",
    _create_elm_library_provider = "create_elm_library_provider",
)

_WELL_KNOWN_PROTOS = [
    "google/protobuf/timestamp.proto",
    "google/protobuf/wrappers.proto",
]

def _elm_proto_aspect_impl(target, ctx):

    args = ctx.actions.args()
    proto = target[ProtoInfo]
    elm_srcs = []
    outpath = None
    for src in proto.direct_sources:
        # Add command line flag for input file.
        base_path = src.path
        if src.root.path != "":
            base_path = base_path[len(src.root.path) + 1:]
        base_path = base_path[len(src.owner.workspace_root) + 0:]
        if base_path in _WELL_KNOWN_PROTOS:
            continue
        args.add_all([base_path])

        # Declare output file. Elm uses capitalized package names.
        output_path = "/".join([
            component.capitalize()
            for component in base_path.split("/")
        ])[:-6] + ".elm"
        # output_path = "bazel-out/k8-fastbuild/bin/Proto/Com/Book.elm"
        output_path = "Proto/Com/Book.elm"
        # out = ctx.actions.declare_file(output_path)
        out = ctx.actions.declare_directory("Proto")
        elm_srcs.append(out)

        # Determine the base output directory for --elm_out.
        if outpath == None:
            outpath = out.root.path + "/" + ctx.label.workspace_root + "/" + ctx.label.package

    if elm_srcs:
        # Invoke the compiler, as one or more source files were provided
        # that actually need building.
        args.add_all([
            "--plugin",
            # EXECUTABLE may be of the form
            # NAME=PATH, in which case the given plugin name
            # is mapped to the given executable even if
            # the executable's own name differs.
            "{NAME}={PATH}".format(NAME = "protoc-gen-elm", PATH = ctx.executable._plugin.path),
            "--elm_out",
            "bazel-out/k8-fastbuild/bin"
            # "."
            # outpath,
        ])
        args.add_all(["json"], before_each = "--elm_opt")
        args.add_all(proto.transitive_proto_path, before_each = "-I")


        # TODO(edsch): This should be removed once this is resolved:
        # https://github.com/bazelbuild/bazel/issues/7964
        args.add_all([
            ctx.genfiles_dir.path + "/" + p
            for p in proto.transitive_proto_path.to_list()
        ], before_each = "-I")
        ctx.actions.run(
            executable = ctx.executable._protoc,
            arguments = [args],
            inputs = proto.transitive_sources.to_list() + [ctx.executable._plugin],
            tools = [ctx.executable._plugin],
            outputs = [
                # out_dir,
                out
                # elm_srcs
            ],
        )
        return [
            _create_elm_library_provider(
                ctx.rule.attr.deps,
                [],
                [],
                [outpath],
                # []
                elm_srcs,
            ),
        ]
    else:
        # No source files to build, as all of them correspond with
        # built-in types.
        return [
            _create_elm_library_provider([], [], [], [], []),
        ]

_elm_proto_aspect = aspect(
    implementation = _elm_proto_aspect_impl,
    attrs = {
        "_protoc": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = Label("@com_google_protobuf//:protoc"),
        ),
        "_plugin": attr.label(
            allow_single_file = True,
            executable = True,
            cfg = "exec",
            default = Label("@com_github_edschouten_rules_elm//tools/protoc-gen-elm:bin"),
        ),
    },

    # {} if _incompatible_toolchains_enabled() else {
    #     "_aspect_proto_toolchain": attr.label(
    #         default = ":python_toolchain",
    #     ),
    # },
    attr_aspects = ["deps"],
    required_providers = [ProtoInfo],
    provides = [_ElmLibrary],
    # toolchains = [
        # "@rules_proto//proto:toolchain_type"
    # ]
    # toolchains = [PY_PROTO_TOOLCHAIN] if _incompatible_toolchains_enabled() else [],
)

def _elm_proto_library_rule(ctx):
    return ctx.attr.proto[_ElmLibrary]

elm_proto_library = rule(
    implementation = _elm_proto_library_rule,
    doc = """""",
    attrs = {
        "proto": attr.label(
            doc = """
              The list of `proto_library` rules to generate Python libraries for.

              Usually this is just the one target: the proto library of interest.
              It can be any target providing `ProtoInfo`.""",
            providers = [ProtoInfo],
            aspects = [_elm_proto_aspect],
        ),
    },
    provides = [_ElmLibrary],
)
