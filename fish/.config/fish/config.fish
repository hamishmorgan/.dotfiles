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

# Useful aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias grep='grep --color=auto'

# Detect OS for conditional configuration loading
set -gx FISH_HOST_OS (uname | awk '{print tolower($0)}')

# Load platform-specific configuration
switch $FISH_HOST_OS
    case darwin
        if test -f ~/.config/fish/config.fish.osx
            source ~/.config/fish/config.fish.osx
        end
    case linux
        if test -f ~/.config/fish/config.fish.linux
            source ~/.config/fish/config.fish.linux
        end
end

# Load dotfiles management function and completions from dot script
if test -f ~/.dotfiles/dot
    source (~/.dotfiles/dot --completion fish | psub)
end

