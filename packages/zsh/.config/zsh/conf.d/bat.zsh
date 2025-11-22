# shellcheck shell=zsh
# Bat (syntax highlighting cat) integration

if command -v batcat &>/dev/null; then
    alias bat='batcat'
    export BAT_CONFIG_PATH="$HOME/.config/bat/config"
elif command -v bat &>/dev/null; then
    export BAT_CONFIG_PATH="$HOME/.config/bat/config"
fi

