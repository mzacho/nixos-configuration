#!/usr/bin/env bash

if [[ "$1" == "-h" ]]; then
  echo "Usage:"
  echo " $(basename $0) <path> : open up file in emacs"
  echo " $(basename $0)        : open up working dir in emacs"
  exit 1
fi

CMD="(find-file \"$1\")"

if [ $(uname -s) = "Linux" ]; then
  emacsclient --socket-name=/run/user/1000/emacs/server \
              --create-frame --no-wait \
              --eval "$CMD"

elif [ $(uname -s) = "Darwin" ]; then
  emacsclient --eval "$CMD"
  osascript -e 'activate application "Emacs"'
fi
