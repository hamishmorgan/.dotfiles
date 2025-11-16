# shellcheck shell=bash
# Dotfiles completions

[[ -f ~/.dotfiles/dot ]] && source <(~/.dotfiles/dot --completion bash 2>/dev/null)

