# shellcheck shell=bash
# Zoxide (smart cd replacement)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)" && alias zi='zoxide query -i'
