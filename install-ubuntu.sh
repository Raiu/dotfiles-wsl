#!/usr/bin/env sh

set -e

[ -z "$XDG_CONFIG_HOME" ]       && export XDG_CONFIG_HOME="${HOME}/.config"
[ -z "$XDG_CACHE_HOME" ]        && export XDG_CACHE_HOME="${HOME}/.cache"
[ -z "$XDG_DATA_HOME" ]         && export XDG_DATA_HOME="${HOME}/.local/share"
[ -z "$XDG_STATE_HOME" ]        && export XDG_STATE_HOME="${HOME}/.local/state"
[ -z "$DOTFILES" ]              && export DOTFILES="${HOME}/.config/dotfiles"
[ -z "$DOTFILES_REPO" ]         && export DOTFILES_REPO="Raiu/dotfiles-wsl"
[ -z "$DOTFILES_REMOTE" ]       && export DOTFILES_REMOTE="https://github.com/${DOTFILES_REPO}.git"
[ -z "$DOTFILES_BRANCH" ]       && export DOTFILES_BRANCH="main"
[ -z "$DOTBOT_DIR" ]            && export DOTBOT_DIR="${DOTFILES}/.dotbot"
[ -z "$DOTBOT_BIN" ]            && export DOTBOT_BIN="${DOTBOT_DIR}/bin/dotbot"
[ -z "$DOTBOT_CONFIG" ]         && export DOTBOT_CONFIG="${DOTFILES}/install.conf.yaml"

PACKAGES_UBUNTU="dialog readline-common apt-utils ssh curl wget sudo bash zsh git vim locales tzdata ca-certificates gnupg python3-minimal zoxide ripgrep"

set -u

     BOLD="$(tput bold 2>/dev/null      || printf '')"
     GREY="$(tput setaf 0 2>/dev/null   || printf '')"
UNDERLINE="$(tput smul 2>/dev/null      || printf '')"
      RED="$(tput setaf 1 2>/dev/null   || printf '')"
    GREEN="$(tput setaf 2 2>/dev/null   || printf '')"
   YELLOW="$(tput setaf 3 2>/dev/null   || printf '')"
     BLUE="$(tput setaf 4 2>/dev/null   || printf '')"
  MAGENTA="$(tput setaf 5 2>/dev/null   || printf '')"
 NO_COLOR="$(tput sgr0 2>/dev/null      || printf '')"

# Helpers
###
_completed()    { printf '%s\n' "${GREEN}✓${NO_COLOR} $*"; }
_info()         { printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"; }
_warn()         { printf '%s\n' "${YELLOW}! $*${NO_COLOR}"; }
_error()        { printf '%s\n' "${RED}x $*${NO_COLOR}" >&2; }
_error_exit()   { _error "$@"; exit 1; }
_exist()        { command -v "$1" 1>/dev/null 2>&1; }

if ! grep -qiE '^ID=ubuntu' /etc/os-release >/dev/null 2>&1; then
        _error_exit "This script has to be run in an Ubuntu environment"
fi

! _exist 'git'  && _error_exit 'install git'
! _exist 'curl' && _error_exit 'install curl'


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


###
# Prime dotfiles
###
is_correct_repo() {
    dir=$1
    url=$2
    GIT_TERMINAL_PROMPT=0 git -C "/tmp" ls-remote --exit-code --heads "$url" \
        >/dev/null 2>&1 || return 1
    url="${url%.git}"
    [ "$(git -C "$dir" rev-parse --is-inside-work-tree 2>/dev/null)" = "true" ] &&
           git -C "$dir" config --get remote.origin.url | grep -qE "^${url}"
}


clone_dotfiles() {
    git clone "$DOTFILES_REMOTE" "$DOTFILES" --recursive
}

run_dotbot() {
    git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
    git -C "${DOTFILES}" submodule update --init --recursive
    "${DOTBOT_BIN}" -d "${DOTFILES}" -c "${DOTBOT_CONFIG}" "${@}"
}

###
# Config ubuntu env
###

setup_locales_deb() {
    $SUDO tee '/etc/locale.gen' > /dev/null << EOF
en_US.UTF-8 UTF-8
en_GB.UTF-8 UTF-8
sv_SE.UTF-8 UTF-8
EOF
    $SUDO locale-gen > /dev/null
    $SUDO tee '/etc/default/keyboard' > /dev/null << EOF
XKBMODEL="pc105"
XKBLAYOUT="se"
XKBVARIANT=""
XKBOPTIONS=""
BACKSPACE="guess"
EOF
}

setup_zsh() {
    printf '# Configuring ZSH\n'
    $SUDO mkdir -p '/etc/zsh'
    
    $SUDO tee '/etc/zsh/zshenv' > /dev/null << 'EOF'
if [[ -z "$PATH" || "$PATH" == "/bin:/usr/bin" ]]
then
        export PATH="/usr/local/bin:/usr/bin:/bin"
fi

# XDG
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share"
export XDG_CONFIG_DIRS="/etc/xdg"

# ZSH
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

# Locales
export LANG="en_GB.UTF-8"
export LANGUAGE="en_GB:en"
export LC_CTYPE="en_GB.UTF-8"
export LC_NUMERIC="sv_SE.utf8"
export LC_TIME="sv_SE.utf8"
export LC_COLLATE="en_GB.UTF-8"
export LC_MONETARY="sv_SE.utf8"
export LC_MESSAGES="en_GB.UTF-8"
export LC_PAPER="sv_SE.utf8"
export LC_NAME="sv_SE.UTF-8"
export LC_ADDRESS="sv_SE.UTF-8"
export LC_TELEPHONE="sv_SE.UTF-8"
export LC_MEASUREMENT="sv_SE.utf8"
export LC_IDENTIFICATION="sv_SE.UTF-8"
export LC_ALL=""
EOF
}

create_xdg_dir() {
    printf '# Creating XDG directories\n'
    #printf '    * root\n'
    $SUDO install -d -m 700 -o root -g root /root/.cache /root/.config \
      /root/.local/share /root/.local/state
    for user_home in /home/*; do
        username=$(basename "$user_home")
        #printf '    * %s\n' "$username"
        $SUDO install -d -m 700 -o "$username" -g "$username" "${user_home}/.cache" \
          "${user_home}/.config" "${user_home}/.local/bin" "${user_home}/.local/state" \
          "${user_home}/.local/share"
    done
}

install_pkg() {
    DEBNI="DEBIAN_FRONTEND=noninteractive"
    NOREC="--no-install-recommends --no-install-suggests"

    printf '# Installing Ubuntu packages\n'
   
    printf '    * Updating repositories\n'
    if [ -f "${DOTFILES}/scripts/update_repo_ubuntu.sh" ] ; then
        $SUDO sh "${DOTFILES}/scripts/update_repo_ubuntu.sh"
        $SUDO $DEBNI apt-get update -y > /dev/null
    else
        $SUDO $DEBNI apt-get update -y > /dev/null
        $SUDO $DEBNI apt-get install $NOREC software-properties-common -y > /dev/null 2>&1
        $SUDO $DEBNI add-apt-repository universe multiverse restricted -y > /dev/null 2>&1
    fi


    printf '    * Upgrading\n'
    $SUDO $DEBNI apt-get upgrade -y > /dev/null
  
    printf '    * Installing packages: %s\n' "$PACKAGES_UBUNTU"
    $SUDO $DEBNI apt-get install $NOREC $PACKAGES_UBUNTU -y > /dev/null 2>&1
  
    printf '    * Cleaning up\n'
    $SUDO $DEBNI apt-get autoremove -y > /dev/null
    $SUDO $DEBNI apt-get clean -y > /dev/null
}

ubuntu_eza_fix() {
    if ! [ -f "/usr/local/bin/eza" ]; then
        $SUDO mkdir -p "/usr/local/bin"
        $SUDO install "${DOTFILES}/bin/bin/eza" "/usr/local/bin/eza"
    fi
}

###
# Run functions
###
main() {

    ###
    printf '# Cloning dotfiles\n'
    if [ -d "$DOTFILES" ]; then
        if ! is_correct_repo "$DOTFILES" "$DOTFILES_REMOTE"; then
            _error_exit "${DOTFILES} already exists and it doesnt contain our repo."
        fi
    else
        clone_dotfiles
    fi

    ###
    install_pkg

    setup_locales_deb

    create_xdg_dir

    setup_zsh

    ubuntu_eza_fix # temp solution to ubuntu eza

    ###
    printf 'Change shell\n'
    $SUDO usermod --shell "$(command -v zsh)" "${REALUSER}" > /dev/null 2>&1

    ###
    printf 'Sudo\n'
    if [ "$(id -u)" -ne 0 ] ; then
        file="/etc/sudoers.d/nopasswd_$REALUSER"
        content="$REALUSER ALL=(ALL:ALL) NOPASSWD: ALL"
        printf "%s" "$content" | $SUDO tee "$file" > /dev/null 2>&1
    fi
    printf "%s" "Defaults !admin_flag" | \
      $SUDO tee "/etc/sudoers.d/disable_admin_file_in_home" > /dev/null 2>&1

    ###
    printf '# Running dotbot\n'
    run_dotbot "${@}"

    ###
    return 0
}


###
# Run
###
main "${@}"
exit 0
