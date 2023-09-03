#!/usr/bin/env bash

echo fixing permissions
sudo chown martin /persist

echo installing home-manager
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
sudo nix-channel --update

echo nixos-rebuild boot
sudo nixos-rebuild boot

echo
msg="Login to protonmail bridge and import emails? (y/n)"
read -p "$msg" confirm

if [[ $confirm == [yY] ]]; then
  echo stopping bridge daemon
  systemctl stop --user protonmail-bridge.service
  echo login to proton:
  protonmail-bridge --cli
  echo starting bridge daemon
  systemctl start --user protonmail-bridge.service
  echo downloading emails
  # make sure offlineimap daemon isn't already running
  systemctl stop --user offlineimap.timer
  systemctl stop --user offlineimap.service
  offlineimap
fi

msg="reboot? (y/n)"
read -p "$msg" x && [[ $x == [yY] ]] && reboot
