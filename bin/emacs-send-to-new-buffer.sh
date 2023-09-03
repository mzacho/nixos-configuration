#!/usr/bin/env bash

set -eu

if [ "$1" == "-h" ]; then
  echo "Usage:"
  echo " <cmd> | $(basename $0) : send cmd output to emacs"
  exit 1
if

# Send stdout and stderr to temporary file
file=/tmp/emacs-buffer-content
cat > $file

EXPR="(new-buffer-from-cmd-output \"$file\" \"$(pwd)\")"

# Open new buffer with file content
if [ $(uname -s) = "Linux" ]; then
  emacsclient --socket-name=/run/user/1000/emacs/server \
              --create-frame --no-wait \
              --eval "$EXPR"

elif [ $(uname -s) = "Darwin" ]; then
  emacsclient --eval --no-wait "$EXPR"
  osascript -e 'activate application "Emacs"'
fi

# Clean up
rm /tmp/emacs-buffer-content
