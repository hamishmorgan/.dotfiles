# shellcheck shell=bash
# bat (syntax highlighting cat)

if command -v batcat &>/dev/null; then
    alias bat='batcat'
fi

# Set config path if either bat or batcat is available
if command -v bat &>/dev/null || command -v batcat &>/dev/null; then
    export BAT_CONFIG_PATH="$HOME/.config/bat/config"
fi

