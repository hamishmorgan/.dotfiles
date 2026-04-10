# shellcheck shell=bash
# Editor detection
if command -v nvim &>/dev/null; then
  export EDITOR="nvim"
elif command -v vim &>/dev/null; then
  export EDITOR="vim"
else
  export EDITOR="vi"
fi
export VISUAL="$EDITOR"
export GIT_EDITOR="$EDITOR"

# Convenience functions
e() { "$EDITOR" "$@"; }
v() { e "$@"; }
