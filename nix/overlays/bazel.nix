final: prev:
let
  bazelisk-bazel = bazelVersion: { bazelisk, makeWrapper, writeShellApplication, coreutils-prefixed }:
    let
      bazelisk' = bazelisk.overrideAttrs (final: prev: {
        nativeBuildInputs = [ makeWrapper ] ++ prev.nativeBuildInputs;
        postFixup = ''wrapProgram $out/bin/bazelisk \
          --set USE_BAZEL_VERSION ${bazelVersion} \
          --prefix PATH : ${coreutils-prefixed}/bin \
          --unset TMP \
          --unset TMPDIR'';
      });
    in
    writeShellApplication {
      name = "bazel";
      runtimeInputs = [ bazelisk' ];
      text = "bazelisk \"$@\"";
    };
in
{
  rulesElm = {
    bazel8 = final.callPackage (bazelisk-bazel "8.1.1") { };
    bazel7 = final.callPackage (bazelisk-bazel "7.5.0") { };
  };
}
