#!/usr/bin/env bash

xrandr --output DP-1 --auto --primary

# move all workspaces to DP-1-1
workspaces=`i3-msg -t get_workspaces | jq '.[] | .num'`

for w in $workspaces; do
  # switch to workspace
  i3-msg workspace $w
  # move it to the DP-1
  i3-msg move workspace to output DP-1
done

# turn off internal laptop monitor
xrandr --output eDP-1 --off

# set kbd layout
xmodmap /etc/nixos/config/X11/Xmodmap-dvorak-kinesis
xset r rate 200 60

# set xresources
xrdb /home/martin/.config/X11/Xresources-home-station
i3-msg 'restart'

sleep 1

# restart urxvt and emacs daemon so dpi settings apply
systemctl restart --user emacs
systemctl restart --user urxvtd.service

# setup apps
# i3-msg exec 'emacsclient -n --create-frame --socket-name=/run/user/1000/emacs/server'
