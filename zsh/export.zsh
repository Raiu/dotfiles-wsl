[ -z "$DOTFILES" ] && export DOTFILES="${HOME}/.config/dotfiles"

export EDITOR=vim
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
[ -z "$VIMDIR" ] && export VIMDIR="$XDG_CONFIG_HOME/vim"
[ -z "$MYVIMRC" ] && export MYVIMRC="$VIMDIR/vimrc"

export TMUXDIR="${XDG_CONFIG_HOME}/tmux"

export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/rg.conf"

export BROWSER="${HOME}/.local/bin/firefox.exe"

export NVM_DIR="$HOME/.config/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
