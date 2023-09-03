#!/usr/bin/env bash

set -ue

name=$1
id=$2

bw get password $id | pbcopy

echo "$name password copied to clipboard (think about where you paste this...)"
