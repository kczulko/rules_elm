# This overlay creates bazel_7 with Artur's actions_patch
# Without this, uglifyjs target fails when 'c opt' passed to bazel
# Issues:
# - https://github.com/NixOS/nixpkgs/pull/262152#issuecomment-1879053113
# - https://github.com/sourcegraph/sourcegraph/pull/59359/files
final: prev:
let
  bazel_7_wrapper = { pkgs
                    # , bazel_7
                    , lib
                    , substituteAll
                    , bash
                    , coreutils
                    , diffutils
                    , file
                    , findutils
                    , gawk
                    , gnugrep
                    , gnupatch
                    , gnused
                    , gnutar
                    , gzip
                    , python313
                    , unzip
                    , which
                    , zip
                    , nodePackages
                    }:
                      let
                        # yanked from https://sourcegraph.com/github.com/NixOS/nixpkgs/-/blob/pkgs/development/tools/build-managers/bazel/bazel_7/default.nix?L77-120
                        defaultShellUtils = [
                          bash
                          coreutils
                          diffutils
                          file
                          findutils
                          gawk
                          gnugrep
                          gnupatch
                          gnused
                          gnutar
                          gzip
                          python313
                          unzip
                          which
                          zip
                        ];
                        unwrapped_bazel_7 = prev.bazel_7.overrideAttrs (oldAttrs:
                          {
                            patches = (oldAttrs.patches or [ ]) ++ [
                              (substituteAll {
                                src = "${pkgs.path}/pkgs/development/tools/build-managers/bazel/bazel_6/actions_path.patch";
                                actionsPathPatch = lib.makeBinPath defaultShellUtils;
                              })
                            ];
                          });
                      in
                        # https://discourse.nixos.org/t/getting-mount-related-error/40262
                        final.writeShellScriptBin "bazel" ''
                            unset TMPDIR TMP
                            exec ${unwrapped_bazel_7}/bin/bazel "$@"
                        '';

in
{

  bazel_7 = prev.callPackage bazel_7_wrapper {};
}
