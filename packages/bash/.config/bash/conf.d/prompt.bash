# shellcheck shell=bash
# Git-aware prompt configuration

git_branch_prompt() {
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    [[ -n "$branch" ]] && echo " ($branch)"
}

PS1='\[\033[34m\]\w\[\033[33m\]$(git_branch_prompt)\[\033[00m\] \[\033[32m\]❯\[\033[00m\] '

