# shellcheck shell=bash
# Bash shell configuration
# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ━━━ History Configuration ━━━
HISTCONTROL=ignoreboth        # Ignore duplicates and space-prefixed
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend           # Append to history file
shopt -s checkwinsize         # Update LINES and COLUMNS after each command

# ━━━ Bash Options ━━━
shopt -s globstar 2>/dev/null # Enable ** globbing (bash 4+, optional)

# ━━━ Completion ━━━
if ! shopt -oq posix; then
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
  elif [[ -f /etc/bash_completion ]]; then
    source /etc/bash_completion
  fi
fi

# ━━━ Prompt ━━━
# Simple, git-aware prompt (branch only, no dirty check for performance)
git_branch_prompt() {
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    [[ -n "$branch" ]] && echo " ($branch)"
}

PS1='\[\033[34m\]\w\[\033[33m\]$(git_branch_prompt)\[\033[00m\] \[\033[32m\]❯\[\033[00m\] '

# ━━━ Detect OS ━━━
export BASH_HOST_OS=$(uname | tr '[:upper:]' '[:lower:]')

# ━━━ Platform-Specific Configuration ━━━
[[ "$BASH_HOST_OS" == "darwin" ]] && [[ -f ~/.bashrc.osx ]] && source ~/.bashrc.osx
[[ "$BASH_HOST_OS" == "linux" ]] && [[ -f ~/.bashrc.linux ]] && source ~/.bashrc.linux

# ━━━ Tool Integrations ━━━

# eza (modern ls)
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

# bat (syntax highlighting cat)
if command -v batcat &>/dev/null; then
    alias bat='batcat'
    export BAT_CONFIG_PATH="$HOME/.config/bat/config"
elif command -v bat &>/dev/null; then
    export BAT_CONFIG_PATH="$HOME/.config/bat/config"
fi

# fzf (fuzzy finder)
if command -v fzf &>/dev/null; then
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

    # Load key bindings if available
    for fzf_bindings in \
        /usr/share/doc/fzf/examples/key-bindings.bash \
        /opt/homebrew/opt/fzf/shell/key-bindings.bash \
        /usr/local/opt/fzf/shell/key-bindings.bash \
        ~/.fzf/shell/key-bindings.bash; do
        [[ -f "$fzf_bindings" ]] && source "$fzf_bindings" && break
    done
fi

# zoxide (smart cd)
command -v zoxide &>/dev/null && eval "$(zoxide init bash)"

# Graphite (stacked PRs)
if command -v gt &>/dev/null; then
    gt_completion=$(gt bash 2>/dev/null)
    [[ -n "$gt_completion" ]] && source <(echo "$gt_completion")
fi

# shadowenv (directory environments)
command -v shadowenv &>/dev/null && eval "$(shadowenv init bash)"

# Dotfiles completions
[[ -f ~/.dotfiles/dot ]] && source <(~/.dotfiles/dot --completion bash 2>/dev/null)

# Shopify dev
[[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]] && source /opt/dev/dev.sh

# Tec agent (Shopify Nix)
[[ -x ~/.local/state/tec/profiles/base/current/global/init ]] && [[ $- == *i* ]] && \
    eval "$(~/.local/state/tec/profiles/base/current/global/init bash)"

# Rust
if command -v rustup &>/dev/null; then
    source <(rustup completions bash rustup 2>/dev/null)
    source <(rustup completions bash cargo 2>/dev/null)
fi
[[ -f ~/.cargo/env ]] && source ~/.cargo/env

# ━━━ Aliases ━━━

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# Editor
alias e='${EDITOR:-nvim}'
alias v='${EDITOR:-nvim}'

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
alias d='dev'

# Common
alias c='clear'

# ━━━ Machine-Specific Configuration ━━━
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
