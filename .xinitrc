#!/bin/bash

# mbsync
systemctl start mbsync.service

# xbindkeys
/usr/bin/xbindkeys -f ~/.config/x/bindkeysrc

# redshift
/usr/bin/redshift -l 50.8503:4.3517 &

# .Xresources
[[ -f ~/.config/x/resources ]] && xrdb -merge ~/.config/x/resources

# start wm
exec i3
