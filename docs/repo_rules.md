<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="elm_repository"></a>

## elm_repository

<pre>
load("@rules_elm//repository:defs.bzl", "elm_repository")

elm_repository(<a href="#elm_repository-name">name</a>, <a href="#elm_repository-patch_args">patch_args</a>, <a href="#elm_repository-patch_cmds">patch_cmds</a>, <a href="#elm_repository-patch_tool">patch_tool</a>, <a href="#elm_repository-patches">patches</a>, <a href="#elm_repository-sha256">sha256</a>, <a href="#elm_repository-strip_prefix">strip_prefix</a>, <a href="#elm_repository-type">type</a>, <a href="#elm_repository-urls">urls</a>)
</pre>

Downloads an Elm package over HTTP, extracts it and creates a
`BUILD.bazel` file containing either an `elm_package()` or `elm_library()`
declaration. For `elm/*` and `elm-explorations/*` an `elm_package()` is
used. For others, `elm_library()` is used to prevent the Elm compiler
from returning hard to debug dependency management related errors.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="elm_repository-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="elm_repository-patch_args"></a>patch_args |  -   | List of strings | optional |  `["-p0"]`  |
| <a id="elm_repository-patch_cmds"></a>patch_cmds |  -   | List of strings | optional |  `[]`  |
| <a id="elm_repository-patch_tool"></a>patch_tool |  -   | String | optional |  `"patch"`  |
| <a id="elm_repository-patches"></a>patches |  List of labels of patches to apply after extraction.   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="elm_repository-sha256"></a>sha256 |  SHA-256 checksum of the tarball.   | String | optional |  `""`  |
| <a id="elm_repository-strip_prefix"></a>strip_prefix |  Directory prefix that may be removed from the files upon extraction.   | String | optional |  `""`  |
| <a id="elm_repository-type"></a>type |  The archive type of the downloaded file. By default, the archive type is determined from the file extension of the URL. If the file has no extension, you can explicitly specify either "zip", "jar", "war", "aar", "nupkg", "tar", "tar.gz", "tgz", "tar.xz", "txz", ".tar.zst", ".tzst", "tar.bz2", ".tbz", ".ar", or ".deb" here.   | String | optional |  `""`  |
| <a id="elm_repository-urls"></a>urls |  List of URLs where the package tarball may be downloaded.   | List of strings | optional |  `[]`  |


