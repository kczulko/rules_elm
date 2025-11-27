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

        ciTargetPkgs = pkgs: with pkgs; [
          # bash
          bazelisk-bazel
          gcc
          # libtool
          nix
          zlib
          nodejs
        ];

        devTargetPkgs = pkgs: (ciTargetPkgs pkgs)+ (with pkgs; [
          python3
          nodePackages.pnpm
          protobuf
        ]);

        shells = {
          ci = pkgs.mkShell { packages = ciTargetPkgs pkgs; };
          default = (pkgs.buildFHSEnv {
            name = "simple-bazelisk-env";
            targetPkgs = devTargetPkgs;
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
