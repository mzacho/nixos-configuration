#!/usr/bin/env bash

# Start xbindkeys if its not already running

if pgrep -x xbindkeys > /dev/null; then
  kill $(pgrep -x xbindkeys)
else
  xbindkeys
fi
