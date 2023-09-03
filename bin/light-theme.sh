#!/usr/bin/env bash

# emacs: dynamically swithing between modus operandi and solarized
# dark needs some work, since the former sets some faces not
# overridden by the latter, and vice-versa
touch ~/.emacs.d/use-light-theme
systemctl restart --user emacs

# X11
if [ `xrdb -get Xft.dpi` = 192 ]; then
  xrdb ~/.config/X11/Xresources-light-192dpi
else
  xrdb ~/.config/X11/Xresources-light-96dpi
fi
# gtk - lxappearance
# rofi

# i3
rm ~/.config/i3/config
ln -s /etc/nixos/config/i3/config-light ~/.config/i3/config
i3-msg 'reload'

# restart urxvt daemon as the very last thing
systemctl restart --user urxvtd.service
