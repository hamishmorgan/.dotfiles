# Fish shell configuration
# ~/.config/fish/config.fish

# Don't show welcome message
set -g fish_greeting

# Set up history
set -g fish_history_max 10000

# # Enable color support
# set -g fish_color_command blue --bold
# set -g fish_color_error red --bold
# set -g fish_color_param normal
# set -g fish_color_comment brblack
# set -g fish_color_operator bryellow
# set -g fish_color_quote green

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Detect OS for conditional configuration loading
set -gx FISH_HOST_OS (string lower (uname))

# Load platform-specific configuration
switch $FISH_HOST_OS
    case darwin
        if test -f ~/.config/fish/config.osx.fish
            source ~/.config/fish/config.osx.fish
        end
    case linux
        if test -f ~/.config/fish/config.linux.fish
            source ~/.config/fish/config.linux.fish
        end
end

# Load dotfiles completions from dot script
# Note: The 'd' function is auto-loaded from ~/.config/fish/functions/d.fish
if test -f ~/.dotfiles/dot
    ~/.dotfiles/dot --completion fish | source
end

# Load private/machine-specific configuration if it exists
# Use this file for secrets, API keys, or machine-specific settings
if test -f ~/.config/fish/config_private.fish
    source ~/.config/fish/config_private.fish
end

