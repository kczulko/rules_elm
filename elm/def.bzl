ElmLibrary = provider()

def _elm_binary_impl(ctx):
    pass

elm_binary = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "main": attr.label(
            allow_files = True,
            mandatory = True,
        ),
    },
    implementation = _elm_binary_impl,
)

def _elm_library_impl(ctx):
    return [
        ElmLibrary(),
    ]

elm_library = rule(
    attrs = {
        "deps": attr.label_list(providers = [ElmLibrary]),
        "srcs": attr.label_list(
            allow_files = True,
            mandatory = True,
        ),
    },
    implementation = _elm_library_impl,
)
