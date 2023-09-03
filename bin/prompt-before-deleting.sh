#!/usr/bin/env bash

read -p "This will remove everything from $1. Are you sure? (y/n) " reply

if ! [[ $reply =~ ^[Yy]$ ]]; then
    echo "Aborting ..."
    exit 1
fi

exit 0
