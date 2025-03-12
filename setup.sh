#!/usr/bin/env sh

set -e

_completed()    { printf '%s\n' "${GREEN}✓${NO_COLOR} $*"; }
_info()         { printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"; }
_warn()         { printf '%s\n' "${YELLOW}! $*${NO_COLOR}"; }
_error()        { printf '%s\n' "${RED}x $*${NO_COLOR}" >&2; }
_error_exit()   { _error "$@"; exit 1; }

BOLD="$(tput bold 2>/dev/null           || printf '')"
GREY="$(tput setaf 0 2>/dev/null        || printf '')"
UNDERLINE="$(tput smul 2>/dev/null      || printf '')"
RED="$(tput setaf 1 2>/dev/null         || printf '')"
GREEN="$(tput setaf 2 2>/dev/null       || printf '')"
YELLOW="$(tput setaf 3 2>/dev/null      || printf '')"
BLUE="$(tput setaf 4 2>/dev/null        || printf '')"
MAGENTA="$(tput setaf 5 2>/dev/null     || printf '')"
NO_COLOR="$(tput sgr0 2>/dev/null       || printf '')"

_completed()    { printf '%s\n' "${GREEN}✓${NO_COLOR} $*"; }
_info()         { printf '%s\n' "${BOLD}${GREY}>${NO_COLOR} $*"; }
_warn()         { printf '%s\n' "${YELLOW}! $*${NO_COLOR}"; }
_error()        { printf '%s\n' "${RED}x $*${NO_COLOR}" >&2; }
_error_exit()   { _error "$@"; exit 1; }
_exist()        { command -v "$1" 1>/dev/null 2>&1; }

set -u

# Print configuration
print_config() {
    _info "Configuration:"
    _info "  DOTFILES:        ${DOTFILES}"
    _info "  DOTFILES_REPO:   ${DOTFILES_REPO}"
    _info "  DOTFILES_BRANCH: ${DOTFILES_BRANCH}"
    _info "  DOTBOT_CONFIG:   ${DOTBOT_CONFIG}"
}

# Check for required commands
check_requirements() {
    _info "Checking requirements..."
    ! _exist 'git'  && _error_exit 'git is not installed. Please install git first.'
    ! _exist 'curl' && _error_exit 'curl is not installed. Please install curl first.'
    
    # Setup sudo if needed
    SUDO=''
    if [ "$(id -u)" -ne 0 ]; then
        ! _exist 'sudo' && _error_exit 'sudo is not installed. Please install sudo first.'
        SUDO=$(command -v 'sudo')
        $SUDO -n false 2>/dev/null && _error_exit 'User does not have sudo permissions.'
    fi
    
    _completed "All requirements satisfied"
}

# Detect distribution
get_distro() {
    _info "Detecting Linux distribution..."
    
    if [ ! -f "/etc/os-release" ]; then
        _error_exit "/etc/os-release does not exist. Cannot determine distribution."
    fi
    
    distro_id=$(grep "^ID=" /etc/os-release | cut -d= -f2 | tr -d '"' | awk '{print tolower($0)}')
    distro_version=$(grep "^VERSION_ID=" /etc/os-release | cut -d= -f2 | tr -d '"')
    
    if [ -z "$distro_id" ]; then
        _error_exit 'ID field not found in /etc/os-release. Cannot determine distribution.'
    fi
    
    _completed "Detected distribution: ${distro_id} ${distro_version}"
    printf '%s' "$distro_id"
}

# Create temporary directory for installation
setup_temp_dir() {
    _info "Setting up temporary directory..."
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT
    cd "$TEMP_DIR"
    _completed "Temporary directory created: ${TEMP_DIR}"
}

# Download installation scripts
download_scripts() {
    _info "Downloading installation scripts..."
    
    # Download the distribution-specific installer
    case "$1" in 
        "ubuntu")
            curl -fsSL "https://raw.githubusercontent.com/${DOTFILES_REPO}/${DOTFILES_BRANCH}/install-ubuntu.sh" -o install-distro.sh
            ;;
        "debian")
            curl -fsSL "https://raw.githubusercontent.com/${DOTFILES_REPO}/${DOTFILES_BRANCH}/install-debian.sh" -o install-distro.sh
            ;;
        "alpine")
            curl -fsSL "https://raw.githubusercontent.com/${DOTFILES_REPO}/${DOTFILES_BRANCH}/install-alpine.sh" -o install-distro.sh
            ;;
        *)
            _error_exit "${1} is not a supported distribution"
            ;;
    esac
    
    chmod +x install-distro.sh
    _completed "Installation scripts downloaded"
}

# Run the installation
run_installation() {
    _info "Starting installation for ${1}..."
    
    # Export all configuration variables so they're available to the installer
    export XDG_CONFIG_HOME
    export XDG_CACHE_HOME
    export XDG_DATA_HOME
    export XDG_STATE_HOME
    export DOTFILES
    export DOTFILES_REPO
    export DOTFILES_REMOTE
    export DOTFILES_BRANCH
    export DOTBOT_DIR
    export DOTBOT_BIN
    export DOTBOT_CONFIG
    export SUDO
    
    # Run the distribution-specific installer
    ./install-distro.sh "${@:2}"
    
    _completed "Installation completed successfully!"
}

# Main function
main() {
    _info "Starting dotfiles installation..."
    print_config
    check_requirements
    distro=$(get_distro)
    setup_temp_dir
    download_scripts "$distro"
    run_installation "$distro" "${@}"
}

# Run the main function
main "${@}"
exit 0
