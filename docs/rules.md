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



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_library-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_library-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="elm_library-strip_import_prefix"></a>strip_import_prefix |  -   | String | optional |  `""`  |


<a id="elm_package"></a>

## elm_package

<pre>
load("@rules_elm//elm:defs.bzl", "elm_package")

elm_package(<a href="#elm_package-name">name</a>, <a href="#elm_package-deps">deps</a>, <a href="#elm_package-srcs">srcs</a>, <a href="#elm_package-package_name">package_name</a>, <a href="#elm_package-package_version">package_version</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_package-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_package-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_package-srcs"></a>srcs |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="elm_package-package_name"></a>package_name |  -   | String | required |  |
| <a id="elm_package-package_version"></a>package_version |  -   | String | required |  |


<a id="elm_test"></a>

## elm_test

<pre>
load("@rules_elm//elm:defs.bzl", "elm_test")

elm_test(<a href="#elm_test-name">name</a>, <a href="#elm_test-deps">deps</a>, <a href="#elm_test-main">main</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_test-deps"></a>deps |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_test-main"></a>main |  -   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


