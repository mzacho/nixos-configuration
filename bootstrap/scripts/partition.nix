{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin
  "partition" (builtins.readFile
    (pkgs.substituteAll {
      name = "foo";
      src = ./partition.sh;
      layout = ../disk/sfdisk-dump;
    }))
