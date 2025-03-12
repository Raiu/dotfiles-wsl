#######################################
#   HELPERS
#######################################

_dedupe_fpath() {
    if [ -n "$FPATH" ]; then
        old_FPATH=$FPATH:
        FPATH=
        while [ -n "$old_FPATH" ]; do
            x=${old_FPATH%%:*}
            case $FPATH: in
            *:"$x":*) ;;
            *) FPATH=$FPATH:$x ;;
            esac
            old_FPATH=${old_FPATH#*:}
        done
        FPATH=${FPATH#:}
        unset old_FPATH x
    fi
}

typeset -g -A _exist_cache
_exist() {
    local cmd="$1"
    [[ -z "$cmd" ]] && return 666
    [[ -v _exist_cache[$cmd] ]] && return ${_exist_cache[$cmd]}
    if command -v "$cmd" >/dev/null 2>&1; then
        _exist_cache[$cmd]=0
        return 0
    else
        _exist_cache[$cmd]=1
        return 1
    fi
}

#######################################
#   Environment Variables
#######################################

export BROWSER="${HOME}/.local/bin/firefox.exe"
export DOTFILES="${DOTFILES:-${HOME}/.config/dotfiles}"
export EDITOR="vim"
export IS_REMOTE=$([ -n "$SSH_CONNECTION" ] && echo true || echo false)
export NVM_DIR="${HOME}/.config/nvm"
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/rg.conf"
export TMUXDIR="${XDG_CONFIG_HOME}/tmux"
export VIMDIR="${VIMDIR:-${XDG_CONFIG_HOME}/vim}"
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
export MYVIMRC="${MYVIMRC:-$VIMDIR/vimrc}"

#######################################
#   GENERAL
#######################################

# OPTIONS
#############################
setopt extended_glob
setopt autocd
setopt histignoredups
setopt HIST_IGNORE_ALL_DUPS
setopt histignorespace
setopt appendhistory
setopt EXTENDED_HISTORY

# History
#############################
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=cyan,bold,underline'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red'

# COMPLETION
#############################
ZSH_DISABLE_COMPFIX=true
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' cache-path "${ZCACHEDIR}/zcompcache"
[[ ":$FPATH:" != *":${ZDOTDIR}/completions:"* ]] && export FPATH="${ZDOTDIR}/completions:$FPATH"
_dedupe_fpath
autoload -Uz compinit
if [ -f "${ZSTATEDIR}/zcompdump" ] &&
    file_mod_time=$(stat -c %Y "${ZSTATEDIR}/zcompdump" 2>/dev/null ||
        stat -f %m "${ZSTATEDIR}/zcompdump" 2>/dev/null) &&
    [ -n "$file_mod_time" ] &&
    (($(date +%s) - file_mod_time <= 24 * 60 * 60)); then
    compinit -C -u
else
    compinit -u
fi

# PURE
#############################
_exist "zoxide" && eval "$(zoxide init zsh)"
autoload -Uz promptinit
promptinit
prompt pure

#######################################
#   OTHER
#######################################

# Avoid duplicate entries in FPATH AND PATH
typeset -U FPATH PATH
