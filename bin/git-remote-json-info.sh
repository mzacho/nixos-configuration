#!/usr/bin/env bash

# Check if the current directory is a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Not a git repository!" 1>&2
    exit 1
fi

# Get all remotes and their URLs
remotes=`git remote -v | awk '{print $1 " " $2 " " $3}'`

# Parse into json array
json=$(python -c "`cat <<EOF
import sys
import json

# parse input to pairs

remotes=[]

for (i, name) in enumerate(sys.argv[2::3]):
    url=sys.argv[i*3+1+2]
    kind=sys.argv[i*3+2+2]
    remotes.append({ "name": name, "url": url, "kind": kind})

print(json.dumps(remotes))

EOF`" -- $remotes)

echo $json | jq
