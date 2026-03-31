# Rust toolchain integration
# shellcheck disable=SC1090
[[ -f ~/.cargo/env ]] && source ~/.cargo/env
if command -v rustup &>/dev/null; then
    # shellcheck disable=SC1090
    source <(rustup completions bash rustup 2>/dev/null)
    # shellcheck disable=SC1090
    source <(rustup completions bash cargo 2>/dev/null)
fi
