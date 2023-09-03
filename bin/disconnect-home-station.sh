#!/usr/bin/env bash

set -e

# turn on internal display
xrandr --output eDP-1 --auto --primary

# move workspaces from secondary external display
workspaces=`i3-msg -t get_workspaces \
  | jq '.[] | select(.output != "eDP-1") | .num'`

for w in $workspaces; do
  # switch to workspace
  i3-msg workspace $w
  # move it to the primary output
  i3-msg move workspace to output primary
done

# turn off external display
xrandr --output DP-1 --off

# set kbd layout
xmodmap /etc/nixos/config/X11/Xmodmap-dvorak-laptop

# load new xresources
xrdb /home/martin/.config/X11/Xresources-default
i3-msg 'restart'

i3-msg workspace 1

# restart urxvt and emacs daemon so dpi settings apply
systemctl restart --user emacs
systemctl restart --user urxvtd.service
