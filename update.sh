#!/usr/bin/env sh

set -e
. "./helpers.sh"
set -u

if [ ! -d "${DOTFILES}" ]; then
    _error_exit "Dotfiles directory not found at ${DOTFILES}. Please install dotfiles first."
fi

if [ ! -d "${DOTFILES}/.git" ]; then
    _error_exit "${DOTFILES} is not a git repository."
fi

current_remote=$(git -C "${DOTFILES}" config --get remote.origin.url || echo "")
if [ -n "${current_remote}" ] && [ "${current_remote}" != "${DOTFILES_REMOTE}" ]; then
    _warn "Remote URL mismatch:"
    _warn "  Current: ${current_remote}"
    _warn "  Expected: ${DOTFILES_REMOTE}"
    printf "%s" "${YELLOW}Do you want to update the remote URL? [y/N]${NO_COLOR} "
    read -r update_remote
    if [ "${update_remote}" = "y" ] || [ "${update_remote}" = "Y" ]; then
        _info "Updating remote URL..."
        git -C "${DOTFILES}" remote set-url origin "${DOTFILES_REMOTE}"
        _completed "Remote URL updated"
    fi
fi

current_branch=$(git -C "${DOTFILES}" symbolic-ref --short HEAD 2>/dev/null || echo "")
if [ -n "${current_branch}" ] && [ "${current_branch}" != "${DOTFILES_BRANCH}" ]; then
    _warn "Branch mismatch:"
    _warn "  Current: ${current_branch}"
    _warn "  Expected: ${DOTFILES_BRANCH}"
    printf "%s" "${YELLOW}Do you want to switch to ${DOTFILES_BRANCH}? [y/N]${NO_COLOR} "
    read -r switch_branch
    if [ "${switch_branch}" = "y" ] || [ "${switch_branch}" = "Y" ]; then
        _info "Switching to branch ${DOTFILES_BRANCH}..."
        git -C "${DOTFILES}" checkout "${DOTFILES_BRANCH}"
        _completed "Switched to branch ${DOTFILES_BRANCH}"
    fi
fi

if [ -n "$(git -C "${DOTFILES}" status --porcelain)" ]; then
    _warn "You have uncommitted changes in your dotfiles repository."
    printf "%s" "${YELLOW}Do you want to stash these changes before pulling? [y/N]${NO_COLOR} "
    read -r stash_changes
    if [ "${stash_changes}" = "y" ] || [ "${stash_changes}" = "Y" ]; then
        _info "Stashing changes..."
        git -C "${DOTFILES}" stash save "Auto-stashed during update on $(date)"
        _completed "Changes stashed"
    else
        _warn "Continuing with uncommitted changes. Pull might fail if there are conflicts."
    fi
fi

_info "Pulling latest changes from ${DOTFILES_REMOTE}..."
pull_output=$(git -C "${DOTFILES}" pull 2>&1) || {
    _error "Failed to pull latest changes:"
    _error "${pull_output}"
    exit 1
}
_completed "Repository updated"

_info "Syncing submodules..."
git -C "${DOTBOT_DIR}" submodule sync --quiet --recursive
_completed "Submodules synced"

_info "Updating submodules..."
git -C "${DOTFILES}" submodule update --init --recursive
_completed "Submodules updated"

_info "Running dotbot to update symlinks..."
"${DOTBOT_BIN}" -d "${DOTFILES}" -c "${DOTBOT_CONFIG}" "${@}"
_completed "Dotfiles update completed successfully!"

post_update_script="${DOTFILES}/scripts/post-update.sh"
if [ -f "${post_update_script}" ] && [ -x "${post_update_script}" ]; then
    _info "Running post-update script..."
    "${post_update_script}"
    _completed "Post-update script completed"
fi

_info "${BLUE}Update Summary:${NO_COLOR}"
_info "  Repository: ${DOTFILES_REPO} (${current_branch})"
_info "  Last commit: $(git -C "${DOTFILES}" log -1 --pretty=format:'%h - %s (%cr)' --abbrev-commit)"
_info "  Total files: $(find "${DOTFILES}" -type f -not -path "*/\.git/*" | wc -l)"

exit 0
