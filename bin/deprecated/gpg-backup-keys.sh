#!/usr/bin/env bash

set -eu

DEST="$USERSPACE_BACKUP/gpg"

if ! [ -d "$DEST" ]; then
    echo "$0: Creating directory $DEST"
    mkdir -p "$DEST"
fi

REPLY=""
# Backup public keys

if [ -f "$DEST/public-keys.asc" ]; then
    read -p "A backup of your public PGP keys already exists in $DEST. Overwrite it? (y/n) " REPLY

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gpg -a --export --armor > "$DEST/public-keys.asc"
        echo "Successfully backed up public keys"
    fi
else
    gpg -a --export --armor > "$DEST/public-keys.asc"
    echo "Successfully backed up public keys"
fi

# Backup private keys

if [ -f "$DEST/private-keys.asc" ]; then
    read -p "A backup of your private PGP keys already exists in $DEST. Overwrite it? (y/n) " REPLY

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gpg -a --export-secret-keys --armor > "$DEST/private-keys.asc"
        echo "Successfully backed up private keys"
    fi
else
    gpg -a --export-secret-keys --armor > "$DEST/private-keys.asc"
    echo "Successfully backed up private keys"
fi

# Backup ownertrust

if [ -f "$DEST/otrust.txt" ]; then
    read -p "A backup of your ownertrust already exists in $DEST. Overwrite it? (y/n) " REPLY

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        gpg --export-ownertrust > "$DEST/otrust.txt"
        echo "Successfully backed up owner trust"
    fi
else
    gpg --export-ownertrust > "$DEST/otrust.txt"
    echo "Successfully backed up owner trust"
fi
