
#!/usr/bin/env bash

xrandr --output DP-1-1 --auto --primary --left-of eDP-1 \
       --output DP-1-3-8 --auto --rotate left --right-of DP-1-1

# move all workspaces to DP-1-1
workspaces=`i3-msg -t get_workspaces | jq '.[] | .num'`

for w in $workspaces; do
  # switch to workspace
  i3-msg workspace $w
  # move it to the DP-1-1
  i3-msg move workspace to output DP-1-1
done

# turn off internal laptop monitor
xrandr --output eDP-1 --off

# set kbd layout
xmodmap /etc/nixos/config/X11/Xmodmap-dvorak-kinesis
xset r rate 200 60


# setup apps
# i3-msg exec 'emacsclient -n --create-frame --socket-name=/run/user/1000/emacs/server'
