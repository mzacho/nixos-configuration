set -eu

# Assumes disks have been partitioned with `partition <device>`
DEVICE=$1
BOOT_PART=${DEVICE}1
ROOT_PART=${DEVICE}2

# Destroy old zfs pool if it exists, e.g. if the script was run before
# but exited due to password mismatch when creating encrypted dataset
if `zpool list -H | grep pool > /dev/null`; then
  zpool destroy pool
fi

# Create root pool on second partition of device
zpool create pool $ROOT_PART


# Create new encrypted dataset
echo prompting for keyphrase for native ZFS encryption "(min 8 chars)"
zfs create -u \
  -o encryption=on \
  -o keylocation=prompt \
  -o keyformat=passphrase \
  pool/encrypted

# TODO: investigate the effect of some of the options, e.g.
#  -o ashift=12 \
#  -o autotrim=on \
#  -o compression=lz4 \

# Create some datasets
zfs create -p pool/encrypted/local/root
zfs create -p pool/encrypted/local/nix
zfs create -p pool/encrypted/persist

# Create an empty snapshot of root before mounting
zfs snapshot pool/encrypted/local/root@blank

echo created zfs pool and datasets:
zfs list -t all

# Mount datasets
zfs set mountpoint=/mnt pool/encrypted/local/root

mkdir -p /mnt/boot
mount $BOOT_PART /mnt/boot

zfs set mountpoint=/mnt/nix \
    pool/encrypted/local/nix
zfs set mountpoint=/mnt/persist \
    pool/encrypted/persist
