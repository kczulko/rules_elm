{
  description = "rules_elm nix flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { ... } @ args: with args;
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            (import ./nix/overlays/bazel.nix)
          ];
        };

        targetPkgs = pkgs: with pkgs; [
          bazelisk-bazel
          python3
          bash
          nodePackages.pnpm
          nix
          coreutils-prefixed
          libtool # for macos build
          protobuf
          nodejs
          zlib
          gcc
        ];

        shells = {
          ci = pkgs.mkShell { packages = targetPkgs pkgs; };
          default = (pkgs.buildFHSEnv {
            name = "simple-bazelisk-env";
            inherit targetPkgs;
          }).env;
        };
      in
      {
        devShells = shells;
        devShell = shells.default;
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
