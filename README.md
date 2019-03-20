# Bazel build rules for Elm

[Elm](https://elm-lang.org/) is a functional programming language that
can be [transpiled](https://en.wikipedia.org/wiki/Source-to-source_compiler)
to Javascript. This repository contains rules for building Elm
applications using [the Bazel build system](https://bazel.build/). These
rules depend on their own copy of the Elm compiler, meaning that Elm and
any libraries used may be versioned as part of your Bazel project.

## Adding these rules to your project

Add the following declarations to your `WORKSPACE` file:

```python
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")

git_repository(
    name = "com_github_edschouten_rules_elm",
    commit = "<fill in the commit hash here>",
    remote = "https://github.com/EdSchouten/rules_elm.git",
)

load("@com_github_edschouten_rules_elm//elm:deps.bzl", "elm_register_toolchains")

elm_register_toolchains()
```

## Build rules provided by this project

### `elm_binary()`

```python
load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_binary")

elm_binary(name, main, deps, visibility)
```

**Purpose:** transpile an Elm application to Javascript. The resulting
Javascript file will be named `${name}.js`.

- `main`: The name of the source file containing the
  [`Program`](https://package.elm-lang.org/packages/elm/core/latest/Platform#Program).
- `deps`: List of `elm_library()` and `elm_package()` targets on which
  the application depends.

### `elm_library()`

```python
load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_library")

elm_library(name, srcs, deps, strip_import_prefix, visibility)
```

**Purpose:** declare a collection of Elm source files that can be reused
by multiple `elm_binary()`s.

- `srcs`: List of source files to package together.
- `deps`: List of `elm_library()` and `elm_package()` targets on which
  the library depends.
- `strip_import_prefix`: Workspace root relative path prefix that should
  be removed from pathname resolution. For example, if the source file
  `my/project/Foo/Bar.elm` contains module `Foo.Bar`,
  `strip_import_prefix` should be set to `my/project` for module
  resolution to work.
