{ pkgs ? import <nixpkgs> {}}:

pkgs.writeShellScriptBin "run-installation"
  (builtins.readFile ./runner.sh)
