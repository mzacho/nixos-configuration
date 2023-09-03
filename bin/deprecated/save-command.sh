#!/usr/bin/env bash

if [ $# -eq 0 ]; then
  echo "usage: $0 <cmd>"
  exit 1
fi

cmd=$@
