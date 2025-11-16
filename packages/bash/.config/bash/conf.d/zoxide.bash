# shellcheck shell=bash
# zoxide (smart cd replacement)

if command -v zoxide &>/dev/null; then
    eval "$(zoxide init bash)"
    alias zi='zoxide query -i'  # Interactive selection
fi

