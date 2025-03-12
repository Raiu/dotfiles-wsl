nvmrc() {
    local path="$(nvm_find_nvmrc)"
    if [ -n "$path" ]; then
        local ver=$(nvm version "$(cat "${path}")")
        if [ "$ver" = "N/A" ]; then
            nvm install
        elif [ "$ver" != "$(nvm version)" ]; then
            nvm use
        fi
    elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] &&
        [ "$(nvm version)" != "$(nvm version default)" ]; then
        echo "Reverting to nvm default version"
        nvm use default
    fi
}

if _exist "eza"; then
    chpwd() {
        eza --icons --group-directories-first
    }
else
    chpwd() {
        LC_COLLATE=C ls -h --group-directories-first --color=auto
    }
fi

if _exist "node"; then
    node() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        node "$@"
    }

    npm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        npm "$@"
    }

    npx() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        npx "$@"
    }

    nvm() {
        unset -f nvm node npm npx
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        nvm "$@"
    }
fi

nvim() {
    unset VIMDIR VIMINIT MYVIMRC
    EDITOR="nvim"
    command nvim "$@"
}
