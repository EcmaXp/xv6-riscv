{
  description = "xv6-riscv development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      rec {
        packages.default = pkgs.symlinkJoin {
          name = "xv6-tools";
          paths = with pkgs; [
            # default
            coreutils
            expect
            gnumake
            perl
            python3
            qemu
            # riscv64
            pkgsCross.riscv64.buildPackages.binutils
            pkgsCross.riscv64.buildPackages.gcc
            pkgsCross.riscv64.buildPackages.gdb
          ];
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ packages.default ];
        };

        apps.qemu = {
          type = "app";
          program = toString (
            pkgs.writeShellScript "run-qemu" ''
              exec make qemu "$@"
            ''
          );
        };
      }
    );
}
