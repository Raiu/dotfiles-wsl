zstyle ':antidote:bundle' use-friendly-names 'yes'

[[ -e "${ZDOTDIR}/antidote" ]] ||
  git clone "https://github.com/mattmc3/antidote.git" "${ZDOTDIR}/antidote"

pl="${ZDOTDIR}/plugin.list"
pb="${ZDOTDIR}/plugin.bundle.zsh"
[[ -f "${pl}" ]] || touch "${pl}"

fpath=("${ZDOTDIR}/antidote/functions" $fpath)
autoload -Uz antidote

if [[ ! "${pb}" -nt "${pl}" ]]; then
  antidote bundle <"${pl}" >|"${pb}"
fi

source "${pb}"
unset pl pb
