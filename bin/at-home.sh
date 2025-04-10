#!/usr/bin/env bash

set -e

# Update Xresources with dpi settings to scale display
sudo nixos-rebuild switch -I nixos-config=/etc/nixos/config-home-station.nix

systemctl restart display-manager.service
