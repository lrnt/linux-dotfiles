# {{{ Alias
alias ls="ls -F --color=always"
alias ll="ls -la"
alias grep="grep --color=always"
alias cp="cp -ia"
alias mv="mv -i"
alias rm="rm -i"
alias ping="ping -c 3"
alias reload="source ~/.zshrc"
# }}}

# {{{ Functions
function extract () {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tbz2 | *.tar.bz2) tar -xvjf  "$1"     ;;
            *.txz | *.tar.xz)   tar -xvJf  "$1"     ;;
            *.tgz | *.tar.gz)   tar -xvzf  "$1"     ;;
            *.tar | *.cbt)      tar -xvf   "$1"     ;;
            *.zip | *.cbz)      unzip      "$1"     ;;
            *.rar | *.cbr)      unrar x    "$1"     ;;
            *.arj)              unarj x    "$1"     ;;
            *.ace)              unace x    "$1"     ;;
            *.bz2)              bunzip2    "$1"     ;;
            *.xz)               unxz       "$1"     ;;
            *.gz)               gunzip     "$1"     ;;
            *.7z)               7z x       "$1"     ;;
            *.Z)                uncompress "$1"     ;;
            *.gpg)       gpg2 -d "$1" | tar -xvzf - ;;
            *) echo "Error: failed to extract $1"   ;;
        esac
    else
        echo "Error: $1 is not a valid file for extraction"
    fi
}

function mkpw() {
    head /dev/urandom | uuencode -m - | sed -n 2p | cut -c1-${1:-8};
}

# original author: antonopa
function to() {
    local wdirs=~/.workdirs

    # no args. do nothing and quit silently
    [[ $# -lt 1 ]] && return 1

    dst=$1

    if [[ $dst == "register" ]] ;
    then
        name=$2
        if [ -z $2 ] ; then
            name=$(basename $(pwd))
        fi

        egrep -q "^${name}" $WORKDIRS && echo "Alias exists" && return
        echo "Registering $(pwd) with alias $name"
        echo "$name $(pwd)" >> $WORKDIRS
        return
    fi

    # is there a conf file?
    [[ ! -f $WORKDIRS ]] && return 2

    dir=$(awk -v wdir=$dst '$1==wdir{print $2}' $WORKDIRS)

    # is the destination in the conf file?
    [[ -z "$dir" ]] && return 4

    pushd $dir
}

function _to() {
    reply=($(awk '{print $1}' $WORKDIRS))
}

# original author: antonopa
function cbuild() {
    dir=build
    clean=0
    cmake_args=""
    target=""

    [[ -f $CBUILDCONF ]] && source $CBUILDCONF && echo "Using defaults: $defargs"

    local OPTIND
    while getopts D:d:t:chi OPTION
    do
        case $OPTION  in
            d)
                dir=$OPTARG
                ;;
            t)
                target=$OPTARG
                ;;
            D)
                cmake_args="$cmake_args -D$OPTARG"
                ;;
            i)
                #ignore default args
                [ ! -z defargs ] && unset defargs
                ;;
            c)
                clean=1
                ;;
            h)
                echo "cbuild -d <build_dir> -t <make_target>"
                echo "defaults will be used if either or all of the arguments"
                echo "aren't specified (build_dir:build make_target:\"\")"
                return
                ;;
        esac
    done
    shift $(($OPTIND-1))

    [[ ! -f CMakeLists.txt ]] && echo "Not a cmake project" && return 1

    [[ ! -d ./$dir ]] && mkdir $dir

    [[ -d ./$dir ]] && [[ $clean -eq 1 ]] && msg "Cleaning old ${dir}" && rm -rf ${dir}/*

    [[ ! -z $defargs ]] && cmake_args="$cmake_args $defargs"

    pushd $dir
    echo "cmake $cmake_args .. make $target"
    cmake $cmake_args .. && make $target
    exitcode=$?
    popd

    return $exitcode
}
# }}}

# {{{ Autocomplete
compctl -K _to to
# }}}
