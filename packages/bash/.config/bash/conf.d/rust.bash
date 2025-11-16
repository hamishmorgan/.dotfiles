# shellcheck shell=bash
# Rust toolchain

if command -v rustup &>/dev/null; then
  source <(rustup completions bash rustup 2>/dev/null)
  source <(rustup completions bash cargo 2>/dev/null)
fi
[[ -f ~/.cargo/env ]] && source ~/.cargo/env

