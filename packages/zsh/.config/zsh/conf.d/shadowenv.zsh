# shellcheck shell=bash
# shadowenv (directory environments) integration

command -v shadowenv &>/dev/null && eval "$(shadowenv init zsh)"

