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
alias grep='grep --color=auto'

# eza configuration (modern ls replacement)
if command -v eza >/dev/null
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --long --header --icons --group-directories-first --git'
    alias la='eza --long --all --header --icons --group-directories-first --git'
    alias lt='eza --tree --level=2 --icons'
    alias lta='eza --tree --level=2 --all --icons'

    # Git-enhanced listing
    alias lg='eza --long --git --git-ignore --icons'

    # Time-sorted
    alias lm='eza --long --sort=modified --reverse --icons'

    # Size-sorted
    alias lz='eza --long --sort=size --reverse --icons'
else
    # Fallback to standard ls aliases if eza not installed
    alias ll='ls -alF'
    alias la='ls -A'
    alias l='ls -CF'
end

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

# bat (modern cat replacement with syntax highlighting)
# Ubuntu/Debian name the binary 'batcat' to avoid conflict with bacula-console-qt
if command -q batcat
    alias bat='batcat'
    set -x BAT_CONFIG_PATH "$HOME/.config/bat/config"
else if command -q bat
    set -x BAT_CONFIG_PATH "$HOME/.config/bat/config"
end
# Optional: Uncomment to replace cat with bat everywhere
# Note: This may break scripts that parse cat output
# alias cat='bat --paging=never'

# Load dotfiles completions from dot script
# Note: The 'd' function is auto-loaded from ~/.config/fish/functions/d.fish
if test -f ~/.dotfiles/dot
    ~/.dotfiles/dot --completion fish | source
end

# Shopify development environment (conditional - safe on all machines)
# dev.fish provides: chruby, nvm, PATH setup, autocomplete
if test -f /opt/dev/dev.fish
    source /opt/dev/dev.fish
end

# Tec agent integration (Shopify's managed Nix environment)
# Note: eval is required - tec init outputs shell-specific code for this shell
if test -x ~/.local/state/tec/profiles/base/current/global/init
    eval "$(~/.local/state/tec/profiles/base/current/global/init fish)"
end

# Rust environment
if type -q rustup
    rustup completions fish rustup | source
end

if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end

# Machine-specific configuration (not version-controlled)
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
