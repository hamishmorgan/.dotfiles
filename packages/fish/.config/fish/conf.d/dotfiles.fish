# Load dotfiles completions from dot script (cached for fast startup)
# Note: The 'd' function is auto-loaded from ~/.config/fish/functions/d.fish
# Completions are auto-loaded from completions/ directory by fish
set -l _dot_completion_cache "$__fish_config_dir/completions/dot.fish"
if test -f ~/.dotfiles/dot; and not test -f $_dot_completion_cache
    mkdir -p (dirname $_dot_completion_cache)
    ~/.dotfiles/dot completion fish > $_dot_completion_cache 2>/dev/null
end
