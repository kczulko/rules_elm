# Bazel build rules for Elm

![CI](https://github.com/kczulko/rules_elm/actions/workflows/workflow.yaml/badge.svg)
![osx_amd64](https://img.shields.io/badge/platform-linux__amd64-orange)
![osx_amd64](https://img.shields.io/badge/platform-osx__arm64-orange)
![osx_amd64](https://img.shields.io/badge/platform-osx__amd64-orange)

[Elm](https://elm-lang.org/) is a functional programming language that
can be [transpiled](https://en.wikipedia.org/wiki/Source-to-source_compiler)
to Javascript. This repository contains rules for building Elm
applications using [the Bazel build system](https://bazel.build/). These
rules depend on their own copy of the Elm compiler, meaning that Elm and
any libraries used may be versioned as part of your Bazel project.

## Adding these rules to your project

Check the [releases](https://github.com/kczulko/rules_elm/releases) for detailed instructions.

## Examples on how to use these rules

- [examples directory](./examples) - contains several 'end to end' projects consuming
  the rules provided by this repository.
- [The Bazel Elm SPA Example repository](https://github.com/EdSchouten/bazel-elm-spa-example) -
  contains a concrete example of how these rules may be used to build a
  web application written in Elm. Might be a bit out of date, however this
  example brings a copy of a well-known demonstration application that
  has been adjusted to be buildable using Bazel.

## Build rules provided by this project

### `elm_binary()`

```python
load("@rules_elm//elm:defs.bzl", "elm_binary")

elm_binary(name, main, deps, visibility)
```

**Purpose:** transpile an Elm application to Javascript. The resulting
Javascript file will be named `${name}.js`.

- `main`: The name of the source file containing the
  [`Program`](https://package.elm-lang.org/packages/elm/core/latest/Platform#Program).
- `deps`: List of `elm_library()` and `elm_package()` targets on which
  the application depends.

**Note:** When the compilation mode (`-c`) is equal to `dbg`, the
resulting Javascript file will have the time traveling debugger enabled.
When the compilation mode is `opt`, optimizations are performed and the
resulting code is minified using UglifyJS.

### `elm_library()`

```python
load("@rules_elm//elm:defs.bzl", "elm_library")

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
load("@rules_elm//elm:defs.bzl", "elm_package")

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

### `elm_proto_library()`

```python
load("@rules_elm//proto:defs.bzl", "elm_proto_library")

elm_proto_library(name, proto, deps, plugin_opt_json, plugin_opt_grpc, visibility)
```

**Purpose:** generate Elm bindings for [Protocol Buffers](https://developers.google.com/protocol-buffers/)
definitions using [protoc-gen-elm](https://www.npmjs.com/package/protoc-gen-elm)
and package them as an `elm_library()`.

- `proto`: The `proto_library()` that should be converted to Elm.
- `deps`: Elm deps required to compile generated code.
- `plugin_opt_json`: One of {json, json=encode, json=decode},
   see [protoc-gen-elm docs](https://www.npmjs.com/package/protoc-gen-elm)
- `plugin_opt_grpc`: One of {grpc, grpc=false, grpc=true},
   see [protoc-gen-elm docs](https://www.npmjs.com/package/protoc-gen-elm)
- `plugin_opt_grpc_dev`: Optional attr which can take following value: `grpcDevTools`,
   see [protoc-gen-elm docs](https://www.npmjs.com/package/protoc-gen-elm)

**Note:** This function is implemented using [Bazel aspects](https://docs.bazel.build/versions/master/skylark/aspects.html),
meaning that it automatically instantiates build rules for all
transitive dependencies of the `proto_library()` and sets up
dependencies between them accordingly.

### `elm_test()`

```python
load("@rules_elm//elm:def.bzl", "elm_test")

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
load("@rules_elm//repository:defs.bzl", "elm_repository")

elm_repository(name, urls, sha256, strip_prefix, patches)
```

**Purpose:** download an Elm package over HTTP, extract it and create a
`BUILD.bazel` file containing either an `elm_package()` or `elm_library()`
declaration. For `elm/*` and `elm-explorations/*` an `elm_package()` is
used. For others, `elm_library()` is used to prevent the Elm compiler
from returning hard to debug dependency management related errors.

- `urls`: List of URLs where the package tarball may be downloaded.
- `sha256`: SHA-256 checksum of the tarball.
- `strip_prefix`: Directory prefix that may be removed from the files
  upon extraction.
- `patches`: List of labels of patches to apply after extraction.
