#!/usr/bin/env sh

set -e

# Import helpers
. "./helpers.sh"

set -u

# Sort Order: Category (see below), then alphabetically within category.
# Categories: Core, Shell, File, Archive, Editors, Network, Dev, Lang, Monitor, Search
PACKAGES_UBUNTU="dialog readline-common apt-utils sudo locales tzdata ca-certificates gnupg bash zsh fzf tmux zoxide mc fd-find rename rsync duf unzip zip tar gzip bzip2 xz-utils vim nvim bat man apropos tldr net-tools iputils traceroute dnsutils ssh curl wget build-essential git python3-minimal htop iotop ripgrep nala"

# Check if running on Ubuntu
if ! grep -qiE '^ID=ubuntu' /etc/os-release >/dev/null 2>&1; then
    _error_exit "This script has to be run in an Ubuntu environment"
fi

# Setup sudo
setup_sudo

###
# Config ubuntu env
###

setup_locales_deb() {
    _info "Setting up locales"
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
    _completed "Locales configured"
}

setup_zsh() {
    _info "Configuring ZSH"
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
    _completed "ZSH configured"
}

create_xdg_dir() {
    _info "Creating XDG directories with secure permissions"

    _info "Setting up XDG directories for root"
    $SUDO install -d -m 700 -o root -g root /root/.cache /root/.config \
      /root/.local/share /root/.local/state

    for user_home in /home/*; do
        username=$(basename "$user_home")

        _info "Setting up XDG directories for user $username"
        $SUDO install -d -m 700 -o "$username" -g "$username" "${user_home}/.cache" \
          "${user_home}/.local/share" "${user_home}/.local/state"

        $SUDO install -d -m 700 -o "$username" -g "$username" "${user_home}/.config"

        if [ -d "${user_home}/.config/zsh" ]; then
            _info "Ensuring correct permissions for existing zsh config directory"
            $SUDO chown -R "$username":"$username" "${user_home}/.config/zsh"
            $SUDO chmod -R 700 "${user_home}/.config/zsh"
        fi
        $SUDO install -d -m 700 -o "$username" -g "$username" "${user_home}/.local/bin"
    done

    _completed "XDG directories created with secure permissions"
}


install_pkg() {
    DEBNI="DEBIAN_FRONTEND=noninteractive"
    NOREC="--no-install-recommends --no-install-suggests"

    _info "Installing Ubuntu packages"

    _info "Updating repositories"
    if [ -f "${DOTFILES}/scripts/update_repo_ubuntu.sh" ] ; then
        $SUDO sh "${DOTFILES}/scripts/update_repo_ubuntu.sh"
        $SUDO $DEBNI apt-get update -y > /dev/null
    else
        $SUDO $DEBNI apt-get update -y > /dev/null
        $SUDO $DEBNI apt-get install $NOREC software-properties-common -y > /dev/null 2>&1
        $SUDO $DEBNI add-apt-repository universe multiverse restricted -y > /dev/null 2>&1
    fi

    _info "Upgrading system packages"
    $SUDO $DEBNI apt-get upgrade -y > /dev/null

    _info "Installing packages: $PACKAGES_UBUNTU"
    $SUDO $DEBNI apt-get install $NOREC $PACKAGES_UBUNTU -y > /dev/null 2>&1

    _info "Cleaning up"
    $SUDO $DEBNI apt-get autoremove -y > /dev/null
    $SUDO $DEBNI apt-get clean -y > /dev/null
    
    _completed "Package installation complete"
}

ubuntu_eza_fix() {
    _info "Setting up eza"
    if ! [ -f "/usr/local/bin/eza" ]; then
        $SUDO mkdir -p "/usr/local/bin"
        $SUDO install "${DOTFILES}/bin/bin/eza" "/usr/local/bin/eza"
    fi
    _completed "Eza setup complete"
}

configure_sudo() {
    _info "Configuring sudo"
    if [ "$(id -u)" -ne 0 ] ; then
        file="/etc/sudoers.d/nopasswd_$REALUSER"
        content="$REALUSER ALL=(ALL:ALL) NOPASSWD: ALL"
        printf "%s" "$content" | $SUDO tee "$file" > /dev/null 2>&1
    fi
    printf "%s" "Defaults !admin_flag" | \
      $SUDO tee "/etc/sudoers.d/disable_admin_file_in_home" > /dev/null 2>&1
    _completed "Sudo configured"
}

run_dotbot() {
    _info "Syncing dotbot submodules"
    git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
    git -C "${DOTFILES}" submodule update --init --recursive
    
    _info "Running dotbot with config: ${DOTBOT_CONFIG}"
    "${DOTBOT_BIN}" -d "${DOTFILES}" -c "${DOTBOT_CONFIG}" "${@}"
    _completed "Dotbot completed successfully"
}

change_shell() {
    _info "Changing default shell to ZSH"
    
    # Check if ZSH is installed
    if ! _exist 'zsh'; then
        _warn "ZSH is not installed. Cannot change shell."
        return 1
    fi
    
    # Get the path to ZSH
    ZSH_PATH=$(command -v zsh)
    
    # Check if ZSH is already in /etc/shells
    if ! grep -q "^${ZSH_PATH}$" /etc/shells; then
        _info "Adding ZSH to /etc/shells"
        echo "${ZSH_PATH}" | $SUDO tee -a /etc/shells > /dev/null
    fi
    
    # Change shell for the current user
    _info "Changing shell for user ${REALUSER}"
    $SUDO chsh -s "${ZSH_PATH}" "${REALUSER}"
    
    _completed "Shell changed to ZSH for ${REALUSER}"
}


###
# Main function
###
main() {
    _info "Starting Ubuntu setup"
    install_pkg
    create_xdg_dir
    setup_locales_deb
    setup_zsh
    ubuntu_eza_fix
    change_shell
    configure_sudo
    run_dotbot "${@}"
    _completed "Ubuntu setup complete! Your environment is ready."
    return 0
}

###
# Run
###
main "${@}"
exit 0