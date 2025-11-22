# shellcheck shell=bash
# Zsh environment file (bootstrap)
# Zsh environment - bootstrap file (must be in $HOME)
# Sets ZDOTDIR to use XDG-compliant location

# Replace ZDOTDIR even if already set (aggressive migration)
# Warn user if ZDOTDIR was previously set
if [[ -n "$ZDOTDIR" ]]; then
    echo "Warning: ZDOTDIR was already set to '$ZDOTDIR', replacing with '$HOME/.config/zsh'" >&2
fi

export ZDOTDIR="$HOME/.config/zsh"

