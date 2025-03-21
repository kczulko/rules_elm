<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="elm_binary"></a>

## elm_binary

<pre>
load("@rules_elm//elm:defs.bzl", "elm_binary")

elm_binary(<a href="#elm_binary-name">name</a>, <a href="#elm_binary-deps">deps</a>, <a href="#elm_binary-main">main</a>)
</pre>

Transpiles an Elm application to Javascript.
The resulting Javascript file will be named `${name}.js`.

**Note:** When the compilation mode (`-c`) is equal to `dbg`, the
resulting Javascript file will have the time traveling debugger enabled.
When the compilation mode is `opt`, optimizations are performed and the
resulting code is minified using UglifyJS.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_binary-deps"></a>deps |  List of `elm_library()` or `elm_package()` targets on which the application depends.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_binary-main"></a>main |  The name of the source file containing the [`Program`](https://package.elm-lang.org/packages/elm/core/latest/Platform#Program).   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="elm_library"></a>

## elm_library

<pre>
load("@rules_elm//elm:defs.bzl", "elm_library")

elm_library(<a href="#elm_library-name">name</a>, <a href="#elm_library-deps">deps</a>, <a href="#elm_library-srcs">srcs</a>, <a href="#elm_library-strip_import_prefix">strip_import_prefix</a>)
</pre>

Declare a collection of Elm source files that can be reused
by multiple `elm_binary()` targets.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_library-deps"></a>deps |  List of `elm_library()` or `elm_package()` targets on which the library depends.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_library-srcs"></a>srcs |  List of source files to package together.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="elm_library-strip_import_prefix"></a>strip_import_prefix |  Workspace root relative path prefix that should be removed from pathname resolution. For example, if the source file `my/project/Foo/Bar.elm` contains module `Foo.Bar`, `strip_import_prefix` should be set to `my/project` for module resolution to work.   | String | optional |  `""`  |


<a id="elm_package"></a>

## elm_package

<pre>
load("@rules_elm//elm:defs.bzl", "elm_package")

elm_package(<a href="#elm_package-name">name</a>, <a href="#elm_package-deps">deps</a>, <a href="#elm_package-srcs">srcs</a>, <a href="#elm_package-package_name">package_name</a>, <a href="#elm_package-package_version">package_version</a>)
</pre>

Makes an off-the-shelf Elm package usable as a dependency.

    **Note:** This function is typically not used directly; it is often
sufficient to use `elm_repository()`.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_package-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_package-deps"></a>deps |  List of packages on which this package depends.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_package-srcs"></a>srcs |  Files that are part of this package. This list **SHOULD** include `"elm.json"`.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="elm_package-package_name"></a>package_name |  The publicly used name of the package (e.g., `elm/json`)   | String | required |  |
| <a id="elm_package-package_version"></a>package_version |  The version of the package (e.g., `1.0.2`).   | String | required |  |


<a id="elm_test"></a>

## elm_test

<pre>
load("@rules_elm//elm:defs.bzl", "elm_test")

elm_test(<a href="#elm_test-name">name</a>, <a href="#elm_test-deps">deps</a>, <a href="#elm_test-main">main</a>)
</pre>

Compiles an Elm testing application to JavaScript and
executes it using Node.js.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_test-deps"></a>deps |  List of `elm_library()` or `elm_package()` targets on which the testing application depends.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_test-main"></a>main |  The name of the source file containing one or more [`Test`s](https://package.elm-lang.org/packages/elm-explorations/test/1.2.1/Test#Test)   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


