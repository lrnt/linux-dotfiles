#!/bin/sh

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

function ensure_link {
    test -L "$HOME/$2" || ln -s "$DIR/$1" "$HOME/$2"
}

ensure_link "vim"           ".vim"
ensure_link "vim/vimrc"     ".vimrc"
ensure_link "awesome"       ".config/awesome"
ensure_link "zsh/zshrc"     ".zshrc"
ensure_link "irssi"         ".irssi"
ensure_link "xbindkeysrc"   ".xbindkeysrc"
