#!/usr/bin/env bash
#
# Removes sub-module $1 from .gitmodules and deletes repo from current
# working directory
#
# Usage:
# $ ./git-submodule-remove.sh compleat
#
# So that for instance
# $ ./git-submodule-add.sh mbrubeck/compleat
# $ ./git-submodule-remove.sh compleat
#
# should yield a clean state

set -eu
set -o pipefail

# source ~/lib/sqlite-helpers

dir=$1
dir_abs=$(pwd)/$dir

# if [ -z "$(select_submodule $dir_abs)" ]; then
#     echo "${dir_abs} does not exist in $db, or it is not a submodule."
#     echo "Installed modules:"
#     echo ""

#     select_all_submodules
#     exit 1
# fi

echo "De-initializing ${dir}"

git submodule deinit -f ${dir_abs}

echo "Removing entry for ${dir} in .gitmodules:"

# Get repo roote dir
root="$(git rev-parse --show-toplevel)"
# Remove entry from .gitmodules
cat "${root}/.gitmodules" | grep -v -F ${dir} > /tmp/.gitmodules

# Show the diff to the user, ignore the exit code
diff /tmp/.gitmodules "${root}/.gitmodules" || true

# Overwrite old .gitmodules
mv /tmp/.gitmodules "${root}/.gitmodules"

echo "Removing files in ${root}/.git/modules"

rm -rf "${root}/.git/modules/${dir}"

# Stage changes, otherwise git rm throws up in 5 lines
git add "${root}/.gitmodules"

echo "Removing files in $(pwd)/${dir}"

rm -rf $(pwd)/${dir}
git rm --cached $(pwd)/${dir} 1>/dev/null

# echo "Removing entry from sqlite db in $db"

# # Show the user what's being deleted
# select_submodule $dir_abs
# delete_where_path $dir_abs

echo "Successfully removed lib ${dir}"
