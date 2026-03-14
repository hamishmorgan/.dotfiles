# shellcheck shell=bash
# Rust toolchain integration
[[ -f ~/.cargo/env ]] && source ~/.cargo/env
if command -v rustup &>/dev/null; then
    source <(rustup completions zsh rustup 2>/dev/null)
    # cargo completions call _arguments at source time, so can't be eval'd.
    # Write to a user-writable fpath dir and let compinit pick it up on next load.
    _cargo_comp_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/completions"
    [[ -d "$_cargo_comp_dir" ]] || mkdir -p "$_cargo_comp_dir"
    # shellcheck disable=SC2206 # zsh array assignment, not bash
    fpath=("$_cargo_comp_dir" $fpath)
    rustup completions zsh cargo > "$_cargo_comp_dir/_cargo" 2>/dev/null
    unset _cargo_comp_dir
fi
