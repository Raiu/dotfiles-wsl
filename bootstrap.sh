#!/usr/bin/env sh

set -e

# Default configuration (can be overridden by environment variables)
: "${XDG_CONFIG_HOME:="${HOME}/.config"}"
: "${DOTFILES:="${XDG_CONFIG_HOME}/dotfiles"}"
: "${DOTFILES_REPO:="Raiu/dotfiles-rem"}"
: "${DOTFILES_BRANCH:="main"}"

# Download and execute the installer
curl -fsSL "https://raw.githubusercontent.com/${DOTFILES_REPO}/${DOTFILES_BRANCH}/install.sh" | sh -s -- "$@"
