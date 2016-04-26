# {{{ Prompt
PROMPT="
%{$fg[red]%}%B%n%b %{$reset_color%}on \
%{$fg[yellow]%}%B%m%b %{$reset_color%}in %{$fg[green]%}%B%~%b
%{$reset_color%}%% "

export PROMPT_EOL_MARK=""
# }}}

# {{{ Git Prompt
RPS1='$(vcs_info && echo $vcs_info_msg_0_)'

GIT_CHANGES="%c%u"
GIT_ACTION="%{$fg[green]%}(%{$reset_color%}\
%{$fg_bold[blue]%}%a%{$reset_color%}\
%{$fg[green]%})%{$reset_color%}"
GIT_BRANCH="%{$fg[green]%}[%{$reset_color%}\
%{$fg[yellow]%}%b%{$reset_color%}\
%{$fg_bold[blue]%}@%{$reset_color%}\
%{$fg[yellow]%}%.7i%{$reset_color%}\
%{$fg[green]%}]%{$reset_color%}"

autoload -Uz vcs_info

zstyle ':vcs_info:git*' check-for-changes true
zstyle ':vcs_info:git*' get-revision true
zstyle ':vcs_info:git*' stagedstr "%{$fg_bold[green]%}*%{$reset_color%}"
zstyle ':vcs_info:git*' unstagedstr "%{$fg_bold[red]%}!%{$reset_color%}"
zstyle ':vcs_info:git*+set-message:*' hooks git-set-message

zstyle ':vcs_info:git*' formats "$GIT_CHANGES $GIT_BRANCH"
zstyle ':vcs_info:git*' actionformats "$GIT_CHANGES $GIT_ACTION $GIT_BRANCH"

+vi-git-untracked(){
    if [[ $(git rev-parse --is-inside-work-tree 2> /dev/null) == 'true' ]] && \
        git status --porcelain | grep '??' &> /dev/null ; then
        hook_com[unstaged]+="%{$fg_bold[red]%}?%{$reset_color%}"
    fi
}

function +vi-git-set-message { +vi-git-untracked ; }
# }}}
