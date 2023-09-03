#!/usr/bin/env bash

set -eu

source ~/.env

# rsync options:
# -a, --archive               archive mode; same as -rlptgoD (no -H)
# -v, --verbose               increase verbosity
# -z, --compress              compress file data during the transfer
# -R, --relative              use relative path names

# secrets/ private stuff
if ! [ -d ~/.emacs.d ]; then
    mkdir ~/.emacs.d
fi
if ! [ -d ~/.ssh ]; then
    mkdir ~/.ssh
fi
rsync -av $USERSPACE_BACKUP/.secret ~
rsync -zRv $USERSPACE_BACKUP/./.emacs.d/diary ~
rsync -zRv $USERSPACE_BACKUP/./.emacs.d/bookmarks ~
rsync -Rv $USERSPACE_BACKUP/./.ssh/id_ed25519 ~
rsync -Rv $USERSPACE_BACKUP/./.ssh/known_hosts ~

# uni
rsync -azv --delete $USERSPACE_BACKUP/Uni ~

# Chrome bookmarks
if ! [ -d ~/Library/Application\ Support/Google ]; then
    mkdir -p ~/Library/Application\ Support/Google
fi
rsync -azRv $USERSPACE_BACKUP/./Chrome/Profile\ 1/Bookmarks ~/Library/\
      Application\ Support/Google

# Ableton
if ! [ -d ~/Library/Preferences/Ableton/Live\ 11.1.6 ]; then
    mkdir -p ~/Library/Preferences/Ableton/Live\ 11.1.6
fi
if ! [ -d ~/Library/Audio/Plug-Ins ]; then
    mkdir -p ~/Library/Audio/Plug-Ins
fi
if ! [ -d ~/Music/Ableton/User\ Library ]; then
    mkdir -p ~/Music/Ableton/User\ Library
fi
if ! [ -d ~/Music/Ableton/Factory\ Packs ]; then
    mkdir -p ~/Music/Ableton/Factory\ Packs
fi
rsync -azRv $DAILY_DRIVE/./Library/Preferences/Ableton/Live\ 11.1.6 ~
rsync -azRv $DAILY_DRIVE/./Library/Audio/Plug-Ins ~
rsync -azRv $DAILY_DRIVE/./Ableton/User\ Library ~/Music
rsync -azRv $DAILY_DRIVE/./Ableton/Factory\ Packs ~/Music

# VMs
if ! [ -z ~/VirtualBox\ VMs ]; then
    mkdir ~/VirtualBox\ VMs
fi
rsync -azRv $USERSPACE_BACKUP/./Virtualbox\ VMs ~
