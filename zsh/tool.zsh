if _exist "vim"; then
    if [ ! -d "$VIMDIR/bundle/Vundle.vim" ]; then
        git clone --quiet "https://github.com/VundleVim/Vundle.vim.git" \
            "$VIMDIR/bundle/Vundle.vim" >/dev/null

        vim -c "execute \"PluginInstall\" | qa"
    fi
fi

if _exist "tmux"; then
    if [[ -z "$TMUX" && "$TERM" != "xterm-256color" ]]; then
        export TERM="xterm-256color"
    elif [[ -n "$TMUX" ]]; then
        export TERM="screen-256color-bce"
    fi

    TMUX_DEFAULT_SESSION="WSL"
    alias tmux="tmux -f ${TMUXDIR}/tmux.conf"
    alias trun="tmux -u a -d -t ${TMUX_DEFAULT_SESSION} 2> /dev/null || tmux -u new -s ${TMUX_DEFAULT_SESSION}"
    if [[ -z "$TMUX" && -z "$VSCODE_NONCE" && -n "$WT_SESSION" && "$IS_REMOTE" == "false" ]]; then
        tmux attach -t $TMUX_DEFAULT_SESSION || tmux new -s $TMUX_DEFAULT_SESSION
    fi
fi
