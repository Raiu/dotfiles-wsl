#!/usr/bin/env sh

: "${XDG_CONFIG_HOME:="${HOME}/.config"}"
: "${XDG_CACHE_HOME:="${HOME}/.cache"}"
: "${XDG_DATA_HOME:="${HOME}/.local/share"}"
: "${XDG_STATE_HOME:="${HOME}/.local/state"}"
: "${DOTFILES:="${XDG_CONFIG_HOME}/dotfiles"}"
: "${DOTFILES_REPO:="Raiu/dotfiles-wsl"}"
: "${DOTFILES_REMOTE:="git@github.com:${DOTFILES_REPO}.git"}"
: "${DOTFILES_BRANCH:="main"}"
: "${DOTBOT_DIR:="${DOTFILES}/.dotbot"}"
: "${DOTBOT_BIN:="${DOTBOT_DIR}/bin/dotbot"}"
: "${DOTBOT_CONFIG:="${DOTFILES}/install.conf.yaml"}"

BOLD="$(tput bold 2>/dev/null      || printf '')"
GREY="$(tput setaf 0 2>/dev/null   || printf '')"
UNDERLINE="$(tput smul 2>/dev/null      || printf '')"
RED="$(tput setaf 1 2>/dev/null   || printf '')"
GREEN="$(tput setaf 2 2>/dev/null   || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null   || printf '')"
BLUE="$(tput setaf 4 2>/dev/null   || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null   || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null      || printf '')"

_completed()    { printf '%s\n' "${GREEN}✓${NO_COLOR} $*"; }
_info()         { printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"; }
_warn()         { printf '%s\n' "${YELLOW}! $*${NO_COLOR}"; }
_error()        { printf '%s\n' "${RED}x $*${NO_COLOR}" >&2; }
_error_exit()   { _error "$@"; exit 1; }
_exist()        { command -v "$1" 1>/dev/null 2>&1; }

setup_sudo() {
    SUDO=''
    if [ "$(id -u)" -ne 0 ]; then
        ! _exist 'sudo' && _error_exit 'sudo is not installed'
        SUDO=$(command -v 'sudo')
        $SUDO -n false 2>/dev/null && _error_exit 'user does not have sudo permissions'
    fi

    if [ -z "${REALUSER:-}" ]; then
        if [ -n "${SUDO_USER:-}" ]; then
            export REALUSER="${SUDO_USER}"
        else
            REALUSER="$(whoami)"
            export REALUSER
        fi
    fi
    
    return 0
}
