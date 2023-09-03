{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin
  "nixos-install-wrapper" (builtins.readFile
    (pkgs.substituteAll {
      name = "foo";
      src = ./nixos-install-wrapper.sh;
      finalize = import ./copy-from-installation-medium-into-persist.nix {};
    }))
