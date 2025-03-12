#!/usr/bin/env sh

nix-channel --remove nixos
nix-channel --remove home-manager

nix-channel --add https://nixos.org/channels/nixos-unstable nixos
nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager

nix-channel --update
