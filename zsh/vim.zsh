if _exist "vim"; then
    if [ ! -d "$VIMDIR/bundle/Vundle.vim" ]; then
        git clone --quiet "https://github.com/VundleVim/Vundle.vim.git" \
            "$VIMDIR/bundle/Vundle.vim" >/dev/null

        vim -c "execute \"PluginInstall\" | qa"
    fi
fi
