# shellcheck shell=bash
# eza (modern ls replacement)

if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --long --header --icons --group-directories-first --git'
  alias la='eza --long --all --header --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons'
  alias lta='eza --tree --level=2 --all --icons'
  alias lg='eza --long --git --git-ignore --icons'
  alias lm='eza --long --sort=modified --reverse --icons'
  alias lz='eza --long --sort=size --reverse --icons'
else
  alias ll='ls -alF'
  alias la='ls -A'
fi

