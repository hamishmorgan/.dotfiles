# shellcheck shell=bash
# direnv (directory environments) integration

command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
