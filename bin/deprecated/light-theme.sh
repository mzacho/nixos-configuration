#!/usr/bin/env bash

set -eu

# set xresources (urxvt colors)
rm ~/.Xresources
ln -s ~/.Xresources.light ~/.Xresources
xrdb ~/.Xresources

# set x background
xsetroot -solid '#fdf6e3'

# set rofi config
rm ~/.config/rofi/config.rasi
ln -s ~/.config/rofi/config-solarized-light.rasi ~/.config/rofi/config.rasi

# set emacs theme
emacsclient -s /run/user/1001/emacs/server --no-wait --eval \
            "(load-theme 'solarized-light)" \
            "(setq sml/theme 'respectful)" \
            "(sml/setup)"

# set i3 theme
rm ~/.config/i3/bar
ln -s ~/.config/i3/solarized-light-bar ~/.config/i3/bar
i3-msg restart
