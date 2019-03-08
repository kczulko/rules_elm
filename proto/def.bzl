#load("//elm:def.bzl", _ElmLibrary = "ElmLibrary")

def _convert_proto_to_elm_path(path):
    components = []
    for component in path.split("/"):
        components.append(component.capitalize())
    return "/".join(components)

def _elm_proto_library_impl(ctx):
    proto = ctx.attr.proto.proto
    elm_srcs = []
    outpath = None
    for src in proto.direct_sources:
        importpath = _convert_proto_to_elm_path(src.dirname)
        out = ctx.actions.declare_file(src.basename[:-len(".proto")].capitalize() + ".elm")
        elm_srcs.append(out)
        if outpath == None:
            outpath = out.dirname if importpath == "." else out.dirname[:-len(importpath)]

    args = ctx.actions.args()
    args.add([
        "--plugin",
        ctx.executable._plugin.path,
        "--elm_out",
        outpath,
    ])
    args.add(proto.direct_sources)
    ctx.actions.run(
        executable = ctx.executable._protoc,
        arguments = [args],
        inputs = proto.direct_sources + [ctx.executable._plugin],
        outputs = elm_srcs,
    )
    return [
        DefaultInfo(files = depset(elm_srcs)),
    ]

elm_proto_library = rule(
    _elm_proto_library_impl,
    attrs = {
        "proto": attr.label(
            mandatory = True,
            providers = ["proto"],
        ),
        #"deps": attr.label_list(providers = [_ElmLibrary]),
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
    },
)
