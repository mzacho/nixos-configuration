{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin
  "init-zfs" (builtins.readFile ./init-zfs.sh)
