# Bazel build rules for Elm

![CI](https://github.com/kczulko/rules_elm/actions/workflows/workflow.yaml/badge.svg)
![osx_amd64](https://img.shields.io/badge/platform-linux__amd64-orange)
![osx_amd64](https://img.shields.io/badge/platform-osx__arm64-orange)
![osx_amd64](https://img.shields.io/badge/platform-osx__amd64-orange)
![Bazel 7](https://img.shields.io/badge/Bazel-7-blue)
![Bazel 8](https://img.shields.io/badge/Bazel-8-blue)

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

## Public API docs

Please check [docs](./docs) directory

- [build rules](./docs/rules.md)
- [repository rules](./docs/repo_rules.md)
