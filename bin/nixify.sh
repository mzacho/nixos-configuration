#!/usr/bin/env bash

## https://github.com/nix-community/nix-direnv/wiki/Shell-integration

if [ ! -e ./.envrc ]; then
  echo "use nix" > .envrc
  direnv allow
fi
if [[ ! -e shell.nix ]] && [[ ! -e default.nix ]]; then
  cat > default.nix <<'EOF'
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  packages = with pkgs; [
      pkgs.go
      pkgs.gopls
      pkgs.delve
      pkgs.go-tools
  ];
}
EOF
fi
