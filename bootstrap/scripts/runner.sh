set -e

echo connect to da net
nmtui

if [ -z $DEVICE ]; then
  echo listing block devices:
  lsblk

  read -p "input device to install to (WARNING: Device will be wiped!!): " DEVICE
  export DEVICE
fi

if [ ! -e $DEVICE ]; then
  echo device $DEVICE not found
  exit 1
fi

if [ -z $RESTIC_REPO ]; then
  echo "input location of /persist restic repo backup"
  echo "Example:"
  echo "  local: ~/mnt/persist"
  echo "  remote: sftp:martin@pi:/mpool/laptop/nixos/persist "
  read -p "" RESTIC_REPO
  export RESTIC_REPO
fi

if [ ! -e $RESTIC_REPO ]; then
  echo repo $RESTIC_REPO not found
  exit 1
fi

if [ -z $RESTIC_PASSWORD ] && [ -z $RESTIC_PASSWORD_FILE ]; then
  echo "RESTIC_PASSWORD and RESTIC_PASSWORD_FILE both unset"
  echo "Repository at $RESTIC_REPO must have been initialized with --insecure-no-password"
  read -p "Continue? (Y/N)" confirm && [[ $confirm == [yY] ]] || exit 1
fi

echo DEVICE=$DEVICE
echo RESTIC_REPO=$RESTIC_REPO
echo RESTIC_PASSWORD=$RESTIC_PASSWORD
echo RESTIC_PASSWORD_FILE=$RESTIC_PASSWORD_FILE
echo
read -p "Continue? $DEVICE will be wiped! (Y/N): " confirm && [[ $confirm == [yY] ]] || exit 1

echo running: partition $DEVICE
source partition

echo restoring /persist from $RESTIC_REPO
restore-persist-from-backup

# echo running: init-zfs /dev/$device
# init-zfs /dev/$device

echo running: nixos-install-wrapper
nixos-install-wrapper
