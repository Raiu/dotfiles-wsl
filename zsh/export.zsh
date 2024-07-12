# Add local bin to path
path=("${HOME}/.local/bin" $path)
export PATH

[ -z "$DOTFILES" ]  && export DOTFILES="${HOME}/.dotfiles"

# Vim
export EDITOR=vim
export VIMINIT='let $MYVIMRC="$XDG_CONFIG_HOME/vim/vimrc" | source $MYVIMRC'
[ -z "$VIMDIR" ]    && export VIMDIR="$XDG_CONFIG_HOME/vim"
[ -z "$MYVIMRC" ]   && export MYVIMRC="$VIMDIR/vimrc"

# Ripgrep
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME}/ripgrep/rg.conf"

export BROWSER="${HOME}/.local/bin/firefox.exe"
