{
  description = "canton-drivers nix flake for dev env and abci app mostly";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { ... } @ args: with args;
    flake-utils.lib.eachDefaultSystem (system:
      let

        bazel7Overlay = import ./nix/overlays/bazel7.nix;

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ bazel7Overlay ];
        };

        shells = {
          default = pkgs.mkShell {
            packages = with pkgs; [
              bazel_7
              nodePackages.pnpm
              gcc14
              python313
              nix
              # for macos pure build:
              libtool
              xcbuild
            ];
          };
        };
      in
      {
        devShells = shells;
        devShell = shells.default;
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
