#!/bin/bash

# xbindkeys
/usr/bin/xbindkeys

# redshift
/usr/bin/redshift -l 48.40:9.983 &

# background
feh --bg-center ~/dotfiles/background.jpg

# .xinitrc.local
[[ -f ~/.xinitrc.local ]] && . ~/.xinitrc.local

# .Xresources
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# start wm
exec i3
