setopt extended_glob
setopt autocd
setopt histignoredups
setopt HIST_IGNORE_ALL_DUPS
setopt histignorespace
setopt appendhistory
setopt EXTENDED_HISTORY


# COMPLETION
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME}/zsh/zcompcache"
zstyle ':completion:*' special-dirs true

# ANTIDOTE
zstyle ':antidote:bundle' use-friendly-names 'yes'

# History
HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=10000
SAVEHIST=10000

# Search history
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=cyan,bold,underline'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red'