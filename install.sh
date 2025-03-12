#!/usr/bin/env sh

set -e

: "${DOTFILES_REPO:="Raiu/dotfiles-rem"}"
: "${DOTFILES_BRANCH:="main"}"

curl -fsSL "https://raw.githubusercontent.com/${DOTFILES_REPO}/${DOTFILES_BRANCH}/install.sh" | sh -s -- "$@"
