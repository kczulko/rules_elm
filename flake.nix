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
          config.allowUnfree = true;
          overlays = [ bazel7Overlay ];
        };

        shells = {
          # default = pkgs.mkShell.override { stdenv = pkgs.llvmPackages.libstdcxxClang.stdenv; } {
          # default = pkgs.mkShell.override { stdenv = pkgs.llvmPackages_18.libcxxStdenv; } {
          # default = pkgs.mkShell.override { stdenv = pkgs.llvmPackages_18.libcxxStdenv; } {
          default = pkgs.mkShell.override { stdenv = pkgs.gcc14Stdenv; } {
            packages = with pkgs; [
              # outa
              bazel_7
              nodePackages.pnpm
              # gcc14
              # python313
              nix
              # for macos pure build:
              
            ] ++ (if pkgs.stdenv.isDarwin then
              [
                libtool
                # xcbuild
                # xcode-install
                # darwin.xcode
                # darwin.CF
              ] else []);
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
