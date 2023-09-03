shopt -s dotglob
set -eu

# echo cp old nixos configuration
mkdir -vp /mnt/etc
# cp -vr @config@ /mnt/etc/nixos
ln -s /mnt/persist/etc/nixos /mnt/etc/nixos


# update initrd.postDeviceCommands in configuration.nix
# BTRFS_ROOT is exported in partition.sh
config=/mnt/etc/nixos/configuration.nix
sed --follow-symlinks -i "/@@SUBSTITUTED_BY_SED@@/s|/dev/[a-Z0-9]*|${BTRFS_ROOT}|g" $config

# Generate new hardware config
nixos-generate-config --root /mnt

echo saving stuff to /persist from installation medium
@finalize@

nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
nix-channel --update

echo nixos-install
cd /mnt && nixos-install

# Remove this so the activation script runs successfully on first boot
rm /mnt/etc/nixos

reboot
