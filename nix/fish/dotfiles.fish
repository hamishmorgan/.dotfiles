# Dotfiles completions (cached for fast startup)
if test -f ~/.dotfiles/dot; and test -x ~/.dotfiles/dot
    set -l _dot_cache "$__fish_config_dir/completions/dot.fish"
    if not test -f $_dot_cache
        mkdir -p (dirname $_dot_cache)
        ~/.dotfiles/dot completion fish > $_dot_cache 2>/dev/null
        and test -s $_dot_cache
        or rm -f $_dot_cache
    end
end
