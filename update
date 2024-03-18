#!/usr/bin/env sh

set -e
[ -z "$XDG_CONFIG_HOME" ]       && export XDG_CONFIG_HOME="${HOME}/.config"
[ -z "$XDG_CACHE_HOME" ]        && export XDG_CACHE_HOME="${HOME}/.cache"
[ -z "$XDG_DATA_HOME" ]         && export XDG_DATA_HOME="${HOME}/.local/share"
[ -z "$XDG_STATE_HOME" ]        && export XDG_STATE_HOME="${HOME}/.local/state"
[ -z "$DOTFILES" ]              && export DOTFILES="${HOME}/.dotfiles"
[ -z "$DOTFILES_REPO" ]         && export DOTFILES_REPO="Raiu/dotfiles-rem"
[ -z "$DOTFILES_REMOTE" ]       && export DOTFILES_REMOTE="https://github.com/${DOTFILES_REPO}.git"
[ -z "$DOTFILES_BRANCH" ]       && export DOTFILES_BRANCH="main"
[ -z "$DOTBOT_DIR" ]            && export DOTBOT_DIR="${DOTFILES}/.dotbot"
[ -z "$DOTBOT_BIN" ]            && export DOTBOT_BIN="${DOTBOT_DIR}/bin/dotbot"
[ -z "$DOTBOT_CONFIG" ]         && export DOTBOT_CONFIG="${DOTFILES}/install.conf.yaml"
set -u

git -C "${DOTFILES}" pull

git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
git -C "${DOTFILES}" submodule update --init --recursive
"${DOTBOT_BIN}" -d "${DOTFILES}" -c "${DOTBOT_CONFIG}" "${@}"