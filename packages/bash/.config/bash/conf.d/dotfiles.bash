# shellcheck shell=bash
# Dotfiles completions (cached for speed)

if [[ -f ~/.dotfiles/dot ]]; then
  _dot_cache="${XDG_CACHE_HOME:-$HOME/.cache}/bash/dot_completion.bash"
  if [[ ! -f "$_dot_cache" ]] || [[ ~/.dotfiles/dot -nt "$_dot_cache" ]]; then
    mkdir -p "$(dirname "$_dot_cache")"
    ~/.dotfiles/dot completion bash >"$_dot_cache" 2>/dev/null
  fi
  # shellcheck source=/dev/null
  [[ -f "$_dot_cache" ]] && source "$_dot_cache"
  unset _dot_cache
fi

