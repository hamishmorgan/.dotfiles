# Editor detection
# Zed and VSCode set env vars in their integrated terminals
# ZED_TERM survives tmux; TERM_PROGRAM doesn't
if [[ -n "${ZED_TERM:-}" ]] || [[ "${TERM_PROGRAM:-}" == "zed" ]]; then
    export EDITOR="zed --wait"
elif [[ -n "${VSCODE_INJECTION:-}" ]] || [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
    export EDITOR="code --wait"
elif command -v nvim &>/dev/null; then
    export EDITOR="nvim"
elif command -v vim &>/dev/null; then
    export EDITOR="vim"
else
    export EDITOR="vi"
fi
export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"

# Convenience functions
e() { eval "$EDITOR" "$@"; }
v() { e "$@"; }
