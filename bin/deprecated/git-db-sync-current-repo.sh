#!/usr/bin/env bash

# Syncs SQLite db in ~/.config/github/local.db with metadata from a
# Git repository. The script is meant to be called from within a root
# directory of a repository. Adds an entry to the db with the
# following metadata:

# - local_directory - Local directory of the repo,
#                     ex. /Users/martinzacho/projects/mu
# - origin          : Name of remote origin
#                     ex. mzacho/mu
# - upstream        : Name of remote upstream
#                     ex. djcb/mu
# - is_fork         : Boolean indicating if repo is a fork
#                     ex. 1
# - is_submodule    : Boolean indicating if repo is a submodule
#                     ex. 0

set -eu

if ! [ -e .git ]; then
    echo "Not a git repo root."
    exit 1
fi

remote_name () {
    # Get second line of git remote -v, something like
    #
    # Fetch URL: git@github.com:djcb/mu.git
    #
    # Cut away git@github.com: and .git to return djcb/mu

    r=$(git remote -v show $1 2>/dev/null | head -n 2 | tail -n 1 | cut -d ":" -f 3)

    echo ${r%.git}
}

path=$(pwd)
origin=$(remote_name origin)
upstream=$(remote_name upstream)
is_fork=$([ -z $upstream ] && echo 0 || echo 1)
is_submodule=$([ -f .git ] && echo 1 || echo 0)

source ~/lib/sqlite-helpers

if ! [ -z "$(select_one_where $path)" ]; then
    delete_where_path $path
fi

insert_into_clones $path ${origin:-"nil"} ${upstream:-"nil"} $is_fork $is_submodule

echo "Added entry to $(basename $db):"
select_one_where $path
