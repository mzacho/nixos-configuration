set -ue

# Usage: DEVICE=/dev/sda partition

# I assume I know what I'm doing when running this script...

# Delete all old partitions and filesystem signatures
sgdisk --zap-all $DEVICE
blkdiscard -f $DEVICE || true

echo "Deleted old partition tables and filesystems!"

# Setup new partitions:
#
# - Creates a new GPT disklabel
# - Creates a new partition of type `EFI System`, 500MiB (boot)
# - Creates a new partition of type `Linux filesystem` to
#     formatted with be btrfs
#
sfdisk $DEVICE < @layout@

prefix=""
if [ -e ${DEVICE}1 ]; then
  prefix=${DEVICE}
elif [ -e ${DEVICE}p1 ]; then
  prefix=${DEVICE}p
else
  echo can\'t guess prefix of partitions
  echo todo: read input from user
  exit 1
fi

boot=${prefix}1
btrfsroot=${prefix}2
# export the btrfs root so it can be used in nixos-install-wrapper
export BTRFS_ROOT=$btrfsroot

# Install filesystem on bootloader partition
mkfs.fat -F 32 $boot
fatlabel $boot NIXBOOT

# Install btrfs as root fs
mkfs.btrfs $btrfsroot

# Create subvolumes and snapshots directiory
mount $btrfsroot /mnt
mkdir /mnt/snapshots
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log

# Snapshot blank root
btrfs subvolume snapshot /mnt/root /mnt/snapshots/root-blank

# Mount filesystems
umount /mnt
mount -o subvol=root    $btrfsroot /mnt
mkdir /mnt/boot
mkdir /mnt/nix
mkdir /mnt/persist
mkdir -p /mnt/var/log

mount                   $boot      /mnt/boot
mount -o subvol=nix     $btrfsroot /mnt/nix
mount -o subvol=persist $btrfsroot /mnt/persist
mount -o subvol=log     $btrfsroot /mnt/var/log
