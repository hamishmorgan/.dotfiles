# Rust environment

# Cache rustup completions (auto-loaded from completions/ by fish)
if command -q rustup
    set -l _rustup_cache "$__fish_config_dir/completions/rustup.fish"
    if not test -f $_rustup_cache
        mkdir -p (dirname $_rustup_cache)
        rustup completions fish rustup > $_rustup_cache 2>/dev/null
    end
end

# Cargo environment (PATH setup - not cacheable)
if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
