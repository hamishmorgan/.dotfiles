# shellcheck shell=bash
# Rust toolchain integration

if command -v rustup &>/dev/null; then
    source <(rustup completions zsh rustup 2>/dev/null)
    source <(rustup completions zsh cargo 2>/dev/null)
fi
[[ -f ~/.cargo/env ]] && source ~/.cargo/env

