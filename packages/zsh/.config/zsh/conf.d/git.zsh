# shellcheck shell=zsh
# Git aliases and shortcuts

# Git
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

# Shopify dev
command -v dev &>/dev/null && alias d='dev'

# Common
alias c='clear'

