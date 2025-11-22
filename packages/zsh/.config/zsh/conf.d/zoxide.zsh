# shellcheck shell=zsh
# zoxide (smart cd replacement) integration

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias zi='zoxide query -i'  # Interactive selection
fi

