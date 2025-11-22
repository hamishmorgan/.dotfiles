# Rust environment
if command -q rustup
    rustup completions fish rustup | source
end

if test -f "$HOME/.cargo/env.fish"
    source "$HOME/.cargo/env.fish"
end
