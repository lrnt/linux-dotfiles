export HISTFILE="${HOME}/.zsh_history"
export HISTSIZE=10000
export SAVEHIST=10000
export EDITOR="vim"
export BROWSER="/usr/bin/chromium"
export XTERM="urxvt"
export PATH=$PATH:$HOME/bin
export WORKDIRS="$HOME/.workdirs"
export CBUILDCONF="$HOME/.cbuild"
export KEYTIMEOUT=1
export PASSWORD_STORE_X_SELECTION="primary"
export PASSWORD_STORE_CLIP_TIME=30

[[ -e "$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh" ]] && \
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/gnupg/S.gpg-agent.ssh"

# Set GPG TTY
export GPG_TTY=$(tty)

# Refresh gpg-agent tty in case user switches into an X session
gpg-connect-agent updatestartuptty /bye >/dev/null
