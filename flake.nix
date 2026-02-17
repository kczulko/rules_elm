{
  description = "rules_elm nix flake";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
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

        ciTargetPkgs = p: (with p; [
          bazelisk-bazel
          gcc
          nix
          zlib
          nodejs
        ]);

        devTargetPkgs = pkgs:
          let
            ciPkgs = (ciTargetPkgs pkgs);
            otherPkgs = with pkgs; [
              python3
              nodePackages.pnpm
              protobuf_33
            ];
          in
            ciPkgs ++ otherPkgs;

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
