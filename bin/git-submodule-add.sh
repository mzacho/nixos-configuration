#!/usr/bin/env bash
#
# Add and initialize a new submodule from Github in the current directory
#
# Usage:
# $ ./git-submodule-add.sh mbrubeck/compleat

set -eu

origin=$1

dir=$(basename ${origin})

git submodule add --name ${dir} git@github.com:${origin}.git ${dir}
git submodule init ${dir}

## Add entry to ~/.config/github/local.db

# source ~/lib/sqlite-helpers

# is_fork=${is_fork:-0}
# is_submodule=1
# dir_abs=$(pwd)/${dir}

# insert_into_clones $dir_abs ${origin:-"nil"} ${upstream:-"nil"} $is_fork $is_submodule

echo "Successfully installed ${dir}"
