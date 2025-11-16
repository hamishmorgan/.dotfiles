# zoxide - smarter cd command
# Tracks your most used directories and lets you jump to them
if type -q zoxide && status is-interactive
    zoxide init fish | source

    # Alias cd to z for smart navigation
    alias cd='z'

    # Alias cdi to zi for interactive selection
    alias cdi='zi'
end
