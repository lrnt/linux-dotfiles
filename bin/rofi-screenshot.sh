#!/usr/bin/env bash

set -e

path=$HOME/screenshots
file=$path/$(date +%F_%H-%M-%S_%N).png
maim_args=

mkdir -p $path

case $1 in
    Select)
        maim_args="-s $file"
    ;;
    All)
        maim_args="$file"
    ;;
    Focused)
        maim_args="-i $(xdotool getactivewindow) $file"
    ;;
    *)
        echo -e 'Select\nAll\nFocused'
    ;;
esac

if [ -z "$maim_args" ]
then
    exit;
fi

coproc {
    sleep 0.1
    maim $maim_args
    notify-send -u low -i image 'Screenshot taken'
    xclip -selection clipboard -t image/png < "$file"
}
