#!/usr/bin/env sh

set -e
. "./helpers.sh"
set -u

"${DOTBOT_BIN}" -d "${DOTFILES}" -c "${DOTBOT_CONFIG}" "${@}"