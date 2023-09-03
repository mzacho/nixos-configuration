#!/usr/bin/env bash

set -eu

# The place where I version control my Chrome extensinos
SRC="${HOME}/.config/chrome/extensions"
# The place where Chrome reads extensions installed into the user space
DEST="${HOME}/Library/Application Support/Google/Chrome/External Extensions"

# Make sure Chrome is installed
if ! brew list google-chrome 1>/dev/null; then
    echo "could not find google-chrome"
    echo "install it with brew install google-chrome"
    exit 1
fi

if ! [ -d "$DEST" ]; then
    # Create DEST if this is the first time running the script
    mkdir -v "$DEST"
else
    # Prune old extensions
    for f in "$DEST"/*.json; do
        fname=$(basename "$f")
        if ! [ -e ${SRC}/$fname ]; then
            echo "pruning old extension $fname since it has been deleted from $SRC"
            rm "$f"
        fi
    done
fi

# Sync extensions
rsync -vtpgo "$SRC/"*.json "$DEST/"

echo "Successfully synced Chrome extensions"
