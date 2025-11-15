# zoxide - smarter cd command
# Tracks your most used directories and lets you jump to them
if type -q zoxide
    zoxide init fish | source
    alias zi='zoxide query -i'  # Interactive selection

    # Usage:
    # z <dir>     - jump to directory
    # zi          - interactive directory selection with fzf
    # z -         - go back to previous directory
end
