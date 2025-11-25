final: prev:
let
  bazelisk-bazel = { bazelisk, makeWrapper, writeShellApplication }:
    let
      bazelisk' = bazelisk.overrideAttrs (final: prev: {
        nativeBuildInputs = [ makeWrapper ] ++ prev.nativeBuildInputs;
        postFixup = ''wrapProgram $out/bin/bazelisk \
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
  bazelisk-bazel = final.callPackage bazelisk-bazel { };
}
