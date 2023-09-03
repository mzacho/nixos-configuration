{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin
  "restore-persist-from-backup"
  (builtins.readFile ./restore-persist-from-backup.sh)
