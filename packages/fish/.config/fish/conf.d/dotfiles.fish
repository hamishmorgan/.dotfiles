# Load dotfiles completions from dot script
# Note: The 'd' function is auto-loaded from ~/.config/fish/functions/d.fish
if test -f ~/.dotfiles/dot
    ~/.dotfiles/dot --completion fish 2>/dev/null | source
end
