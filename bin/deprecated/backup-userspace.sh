#!/usr/bin/env bash

set -eu

source "$HOME/.env"

# -a, --archive               archive mode; same as -rlptgoD (no -H)
# -v, --verbose               increase verbosity
# -z, --compress              compress file data during the transfer
# -R, --relative              use relative path names

# secrets/ private stuff
rsync -av --delete ~/.secret $USERSPACE_BACKUP
rsync -zRv ~/./.emacs.d/diary $USERSPACE_BACKUP
rsync -zRv ~/./.emacs.d/bookmarks $USERSPACE_BACKUP
rsync -Rv ~/./.ssh/id_ed25519 $USERSPACE_BACKUP
rsync -Rv ~/./.ssh/known_hosts $USERSPACE_BACKUP

# uni
rsync -azv --delete ~/Uni $USERSPACE_BACKUP

# Ableton
rsync -azRv ~/./Library/Preferences/Ableton/Live\ 11.1.6 $DAILY_DRIVE
rsync -azRv ~/./Library/Audio/Plug-Ins $DAILY_DRIVE
rsync -azRv --delete ~/Music/./Ableton/User\ Library $DAILY_DRIVE
rsync -azRv --delete ~/Music/./Ableton/Factory\ Packs $DAILY_DRIVE

# VMs
rsync -azRv ~/./VirtualBox\ VMs $USERSPACE_BACKUP
