[ -z "$DOTFILES" ] && export DOTFILES="${HOME}/.config/dotfiles"

export EDITOR=vim

if [[ -n "$SSH_CONNECTION" || -n "$SSH_TTY" || -n "$SSH_CLIENT" ]]; then
    export IS_REMOTE=true
else
    export IS_REMOTE=false
fi

[ -z "$VIMDIR" ] && export VIMDIR="$XDG_CONFIG_HOME/vim"
#export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
#[ -z "$MYVIMRC" ] && export MYVIMRC="$VIMDIR/vimrc"

export TMUXDIR="${XDG_CONFIG_HOME}/tmux"

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/rg.conf"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

export BROWSER="${HOME}/.local/bin/firefox.exe"

