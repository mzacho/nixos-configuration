{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix>

    # # Provide an initial copy of the NixOS channel so that the user
    # # doesn't need to run "nix-channel --update" first.
    # <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
    <home-manager/nixos>
  ];

  config = {
    # nix.nixPath = [
    #   "home-manager=${/home/martin/projects/home-manager}"
    # ];

    # Use nmtui in the installer
    networking.wireless.enable = false;
    networking.networkmanager.enable = true;
    networking.extraHosts = ''
      192.168.1.150 pi
    '';

    # Faster compression / larger ISO
    isoImage.squashfsCompression = "gzip -Xcompression-level 1";

    boot.postBootCommands =
      ''

      '';

    environment.extraInit =
      ''
      export RESTIC_PASSWORD_FILE=${/persist/restic-password.txt}
      mkdir mnt
      lsblk
      echo
      echo start installation with
      echo $ sudo DEVICE=/dev/nvme0n1 RESTIC_REPO=~/mnt/persist run-installation
      '';

    environment.systemPackages = with pkgs; [
      (callPackage ./scripts/partition.nix {})
      (callPackage ./scripts/restore-persist-from-backup.nix {})
      (callPackage ./scripts/nixos-install-wrapper.nix {})
      (callPackage ./scripts/runner.nix {})
      emacs29
      git
      # scripts dependencies
      dosfstools
      gptfdisk
      util-linux
      restic
    ];
  };
}
