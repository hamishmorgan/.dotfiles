# Fish shell configuration
# ~/.config/fish/config.fish

# Don't show welcome message
set -g fish_greeting

# Set up history
set -g fish_history_max 10000

# Enable color support
set -g fish_color_command blue --bold
set -g fish_color_error red --bold
set -g fish_color_param normal
set -g fish_color_comment brblack
set -g fish_color_operator bryellow
set -g fish_color_quote green

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

# Machine-specific configuration (not version-controlled)
# should be added to ~/.config/fish/conf.d/
