#!/usr/bin/env bash

shopt -s nullglob globstar

# Handle argument.
if [ ! -z "$@" ]
then
    coproc { pass -c "$@"; notify-send "Password $@ copied to clipboard"; }
    exit;
fi

# Print password list
prefix=${PASSWORD_STORE_DIR-~/.password-store}
password_files=( "$prefix"/**/*.gpg )
password_files=( "${password_files[@]#"$prefix"/}" )
password_files=( "${password_files[@]%.gpg}" )

printf "%s\n" "${password_files[@]}"
