args: import ./nixpkgs.nix {
  overlays = [
    (import ./overlays/bazel.nix)
  ];
}
