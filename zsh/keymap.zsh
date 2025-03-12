# History
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
bindkey '^[[1;5A' history-beginning-search-backward
bindkey '^[[1;5B' history-beginning-search-forward

# Movement
bindkey "^[Od" backward-word
bindkey "^[Oc" forward-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
