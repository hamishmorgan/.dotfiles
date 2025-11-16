# shellcheck shell=bash
# Git aliases and configuration

if command -v git &>/dev/null; then
  alias g='git'
  alias gs='git status'
  alias ga='git add'
  alias gc='git commit'
  alias gp='git push'
  alias gl='git pull'
  alias gd='git diff'
  alias glog='git log --oneline --graph --decorate'

  # Git worktree
  alias gwt='git worktree'
  alias gwta='git worktree add'
  alias gwtl='git worktree list'
  alias gwtr='git worktree remove'
fi

