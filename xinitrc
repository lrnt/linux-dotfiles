#!/bin/bash

# xbindkeys
/usr/bin/xbindkeys

# udiskey
/usr/bin/udiskie & > /dev/null

# redshift
/usr/bin/redshift -l 48.40:9.983 &

# awesome 
exec /usr/bin/awesome >> ~/.cache/awesome/stdout 2>> ~/.cache/awesome/stderr
