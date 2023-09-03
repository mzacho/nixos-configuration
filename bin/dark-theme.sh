#!/usr/bin/env bash

# emacs
rm -f ~/.emacs.d/use-light-theme
systemctl restart --user emacs

# X11
if [ `xrdb -get Xft.dpi` = 192 ]; then
  xrdb ~/.config/X11/Xresources-dark-192dpi
else
  xrdb ~/.config/X11/Xresources-dark-96dpi
fi

# gtk - lxappearance
# rofi

# i3
rm ~/.config/i3/config
ln -s /etc/nixos/config/i3/config ~/.config/i3/config
i3-msg 'reload'

systemctl restart --user urxvtd.service
