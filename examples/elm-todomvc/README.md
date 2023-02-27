# [TodoMVC](https://github.com/evancz/elm-todomvc) with a bazel build

This example shows how to build well-known `elm-todomvc` project. It consists from two elm targets:
`:app` and `:elm`. Additionally http server was added to expose the web page locally.

To run the app, please execute:
```
$ bazel run :dev-server
```
