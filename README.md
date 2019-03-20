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

### `elm_package()`

```python
load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_package")

elm_package(name, package_name, package_version, srcs, deps, visibility)
```

**Purpose:** make an off-the-shelf Elm package usable as a dependency.

- `package_name`: The publicly used name of the package (e.g.,
  `elm/json`).
- `package_version`: The version of the package (e.g., `1.0.2`).
- `srcs`: Files that are part of this package. This list **SHOULD**
  include `"elm.json"`.
- `deps`: List of packages on which this package depends.

**Note:** This function is typically not used directly; it is often
sufficient to use `elm_repository()`.

### `elm_test()`

```python
load("@com_github_edschouten_rules_elm//elm:def.bzl", "elm_test")

elm_test(name, main, deps, visibility)
```

**Purpose:** compile an Elm testing application to Javascript and
execute it using Node.js.

- `main`: The name of the source file containing one or more
  [`Test`s](https://package.elm-lang.org/packages/elm-explorations/test/1.2.1/Test#Test)
- `deps`: List of `elm_library()` and `elm_package()` targets on which
  the testing application depends.

## Repository rules provided by this project

### `elm_repository()`

```python
load("@com_github_edschouten_rules_elm//repository:def.bzl", "elm_repository")

elm_repository(name, urls, sha256, strip_prefix)
```

**Purpose:** download an Elm package over HTTP, extract it and create a
`BUILD.bazel` file containing an `elm_package()` declaration.

- `urls`: List of URLs where the package tarball may be downloaded.
- `sha256`: SHA-256 checksum of the tarball.
- `strip_prefix`: Directory prefix that may be removed from the files
  upon extraction.
