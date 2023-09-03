#!/usr/bin/env bash

set -eu

pattern=$1
replacement=${2:-""}

for f in *; do
  if [[ "$f" == *"$pattern"* ]]; then
    mv "$f" "${f/$pattern/$replacement}"
  fi
done
