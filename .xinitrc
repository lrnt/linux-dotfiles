#!/bin/bash

# set PATH
export PATH="$HOME/bin:$PATH"

# start user services
systemctl --user import-environment DISPLAY XAUTHORITY PATH
systemctl --user start dunst.service
systemctl --user start xautolock.service

# xbindkeys
/usr/bin/xbindkeys -f ~/.config/x/bindkeysrc

# redshift
/usr/bin/redshift -l 50.8503:4.3517 &

# .Xresources
[[ -f ~/.config/x/resources ]] && xrdb -merge ~/.config/x/resources

# set wallpaper
feh --bg-fill "$HOME/.wallpaper.jpg"

# Set DPI
xrandr --dpi 166

# start wm
exec i3
