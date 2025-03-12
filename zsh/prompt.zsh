if _exist "eza"; then
    chpwd() {
        eza --icons --group-directories-first
    }
else
    chpwd() {
        LC_COLLATE=C ls -h --group-directories-first --color=auto
    }
fi

[[ ":$FPATH:" != *":${ZDOTDIR}/completions:"* ]] && export FPATH="${ZDOTDIR}/completions:$FPATH"

_exist "zoxide" && eval "$(zoxide init zsh)"

autoload -U compinit promptinit
promptinit
prompt pure
compinit
