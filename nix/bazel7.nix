with import <nixpkgs> { config = {}; overlays = [ (import ./overlays/bazel7.nix) ]; };
bazel_7
