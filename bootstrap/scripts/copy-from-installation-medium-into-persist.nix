{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScript
  "copy-from-installation-medium-into-persist"
  (builtins.readFile ./copy-from-installation-medium-into-persist.sh)
