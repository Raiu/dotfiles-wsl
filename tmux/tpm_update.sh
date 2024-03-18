#!/usr/bin/env sh

REPO_URL="https://github.com/tmux-plugins/tpm"
REPO_DIR="plugins/tpm"
UPDATE_FILE=".tpm_update"
UPDATE_INTERVAL=604800

SH_DIR=$(dirname "$0")
REPO_DIR="${SH_DIR}/${REPO_DIR}"
UPDATE_FILE="${SH_DIR}/${UPDATE_FILE}"

if [ -e "$UPDATE_FILE" ] && 
  [ $(($(date +%s) - $(stat -c%Y "$UPDATE_FILE"))) -lt $UPDATE_INTERVAL ]; then
    exit 0
fi

if [ ! -d "$REPO_DIR" ]; then
    git clone "$REPO_URL" "$REPO_DIR"
else
    (cd "$REPO_DIR" && git pull > /dev/null)
fi

touch "$UPDATE_FILE"
