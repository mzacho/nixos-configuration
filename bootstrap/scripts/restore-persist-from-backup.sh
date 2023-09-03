set -e

# # Install ssh key from yubikey
# mkdir -p ~/.ssh
# ssh-keygen -K
# # keys saved to ~/.ssh/id_ed25519_sk_rk
# mv ~/.ssh/id_ed25519_sk_rk ~/.ssh/id_ed25519_sk
# mv ~/.ssh/id_ed25519_sk_rk.pub ~/.ssh/id_ed25519_sk.pub

no_password_opt=""
if [ -z $RESTIC_PASSWORD ] && [ -z $RESTIC_PASSWORD_FILE ]; then
  no_password_opt="--insecure-no-password"
fi

# restore /persist from backup
restic --verbose $no_password_opt \
       --repo=$RESTIC_REPO \
       restore latest --target /mnt/persist

# unpack into /persist
mv /mnt/persist/persist/* /mnt/persist/
rmdir /mnt/persist/persist
