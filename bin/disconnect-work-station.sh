#!/usr/bin/env bash

set -e

# turn off main external display
xrandr --output eDP-1 --auto --primary \
       --output DP-1-1 --off

# move workspaces from secondary external display
workspaces=`i3-msg -t get_workspaces \
  | jq '.[] | select(.output != "eDP-1") | .num'`

for w in $workspaces; do
  # switch to workspace
  i3-msg workspace $w
  # move it to the primary output
  i3-msg move workspace to output primary
done

# turn off secondary external display
xrandr --output DP-1-3-8 --off

# set kbd layout
xmodmap /etc/nixos/config/X11/Xmodmap-dvorak-laptop

i3-msg workspace 1
