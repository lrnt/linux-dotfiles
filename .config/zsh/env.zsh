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

[[ -e "$XDG_RUNTIME_DIR/ssh-agent.socket" ]] && \
    export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
