<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="elm_register_toolchains"></a>

## elm_register_toolchains

<pre>
load("@rules_elm//elm:repositories.bzl", "elm_register_toolchains")

elm_register_toolchains(<a href="#elm_register_toolchains-register">register</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="elm_register_toolchains-register"></a>register |  <p align="center"> - </p>   |  `True` |


<a id="elm_compiler_repository"></a>

## elm_compiler_repository

<pre>
load("@rules_elm//elm:repositories.bzl", "elm_compiler_repository")

elm_compiler_repository(<a href="#elm_compiler_repository-name">name</a>, <a href="#elm_compiler_repository-platform">platform</a>, <a href="#elm_compiler_repository-repo_mapping">repo_mapping</a>)
</pre>

Fetching external elm compiler

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_compiler_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_compiler_repository-platform"></a>platform |  -   | String | required |  |
| <a id="elm_compiler_repository-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |


<a id="elm_toolchains_repository"></a>

## elm_toolchains_repository

<pre>
load("@rules_elm//elm:repositories.bzl", "elm_toolchains_repository")

elm_toolchains_repository(<a href="#elm_toolchains_repository-name">name</a>, <a href="#elm_toolchains_repository-repo_mapping">repo_mapping</a>, <a href="#elm_toolchains_repository-toolchain">toolchain</a>)
</pre>

All default elm toolchains

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_toolchains_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_toolchains_repository-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |
| <a id="elm_toolchains_repository-toolchain"></a>toolchain |  Label of the toolchain with {platform} left as placeholder. example; @elm_{platform}//:crane_toolchain   | String | optional |  `""`  |


