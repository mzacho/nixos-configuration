#!/usr/bin/env bash

set -ue

ID=$1

echo "adding extension with id $1 to ~/.config/chrome/extensions/"

cp ~/.config/chrome/extensions/template \
   ~/.config/chrome/extensions/${ID}.json

~/bin/chrome-sync-extensions.sh
