alias _='sudo '
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias md='mkdir -p'
alias rd='rmdir'

alias egrep='grep -E --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias fgrep='grep -F --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox}'
alias screen='screen -e^tt'
alias wget='wget --hsts-file ${XDG_CACHE_HOME}/wget/wget-hsts'
alias lg='lazygit'

_exist "batcat" && alias bat="batcat"
_exist "fdfind" && alias fd="fdfind"

if _exist "eza"; then
    alias ls='eza --icons --group-directories-first'
    alias lsa='eza -a --icons --group-directories-first'
    alias lt='eza -T --group-directories-first --icons --git'
    alias lta='eza -Ta --group-directories-first --icons --git'
    alias ll='eza -lmh --group-directories-first --color-scale --icons'
    alias la='eza -lamhg --group-directories-first --color-scale --icons --git'
    alias laa='eza -lamhg@ --group-directories-first --color-scale --icons --git'
    alias lx='eza -lbhHigUmuSa@ --group-directories-first --color-scale --icons --git --time-style=long-iso'
else
    alias ls='LC_COLLATE=C ls -h --group-directories-first --color=auto'
    alias lsa='LC_COLLATE=C ls -Ah --group-directories-first --color=auto'
    alias ll='LC_COLLATE=C ls -lh --group-directories-first --color=auto'
    alias la='LC_COLLATE=C ls -lAh --group-directories-first --color=auto'
fi

alias dc='docker compose'
alias dcd='docker compose down'
alias dcs='docker compose up -d'
alias dcr='docker compose restart'
alias dcu='docker compose down && docker compose pull && docker compose up -d'

alias tm='tmux'
alias tma='tm attach-session'
alias tmat='tma -t'
alias tmks='tm kill-session -a'
alias tml='tm list-sessions'
alias tmn='tm new-session'
alias tmns='tmn -s'

alias zre='source "${ZDOTDIR}/.zshrc"'
alias zed='vim "${ZDOTDIR}/.zshrc"'
alias ved='vim "${VIMDIR}/vimrc"'
alias zalias='vim "${ZDOTDIR}/alias.zsh"'

alias cdc='cd /mnt/c/'
alias cdd='cd /mnt/d/'
alias explorer='explorer.exe .'
