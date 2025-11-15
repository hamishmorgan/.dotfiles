# shellcheck shell=bash
# shellcheck disable=SC2296,SC2016,SC1036,SC1073,SC1072,SC1009
# SC2296: Zsh parameter expansion syntax
# SC2016: Zsh prompt uses single quotes intentionally
# SC1036,SC1073,SC1072,SC1009: Zsh glob qualifiers for completion caching
# Zsh shell configuration
# ~/.zshrc

# ━━━ History Configuration ━━━
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory          # Append to history file
setopt sharehistory           # Share history between sessions
setopt incappendhistory       # Add commands immediately
setopt histignoredups         # Ignore duplicate commands
setopt histfindnodups         # Don't show duplicates in search
setopt histreduceblanks       # Remove superfluous blanks

# ━━━ Completion System ━━━
autoload -Uz compinit

# Cache completions for 24 hours for faster startup
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Better completion menu
zstyle ':completion:*' menu select
# Color completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# ━━━ Directory Navigation ━━━
setopt autocd                 # cd by typing directory name
setopt autopushd              # Push directories to stack
setopt pushdsilent            # Don't print stack
setopt pushdtohome            # pushd with no args goes home

# ━━━ Key Bindings ━━━
bindkey -e                    # Emacs key bindings
bindkey '^[[A' history-search-backward  # Up arrow
bindkey '^[[B' history-search-forward   # Down arrow

# ━━━ Prompt ━━━
autoload -Uz vcs_info
precmd() {
    vcs_info
}
setopt prompt_subst

# Git info in prompt
zstyle ':vcs_info:git:*' formats ' (%b%u%c)'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'

PROMPT='%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f %F{green}❯%f '

# ━━━ Detect OS ━━━
export ZSH_HOST_OS=$(uname | tr '[:upper:]' '[:lower:]')

# ━━━ Platform-Specific Configuration ━━━
[[ "$ZSH_HOST_OS" == "darwin" ]] && [[ -f ~/.zshrc.osx ]] && source ~/.zshrc.osx
[[ "$ZSH_HOST_OS" == "linux" ]] && [[ -f ~/.zshrc.linux ]] && source ~/.zshrc.linux

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
        /usr/share/doc/fzf/examples/key-bindings.zsh \
        /opt/homebrew/opt/fzf/shell/key-bindings.zsh \
        /usr/local/opt/fzf/shell/key-bindings.zsh \
        ~/.fzf/shell/key-bindings.zsh; do
        [[ -f "$fzf_bindings" ]] && source "$fzf_bindings" && break
    done
fi

# zoxide (smart cd)
command -v zoxide &>/dev/null && eval "$(zoxide init zsh)"

# Graphite (stacked PRs)
if command -v gt &>/dev/null; then
    local gt_completion
    gt_completion=$(gt zsh 2>/dev/null) && [[ -n "$gt_completion" ]] && source <(echo "$gt_completion")
fi

# shadowenv (directory environments)
command -v shadowenv &>/dev/null && eval "$(shadowenv init zsh)"

# Dotfiles completions
[[ -f ~/.dotfiles/dot ]] && source <(~/.dotfiles/dot --completion zsh 2>/dev/null)

# Shopify dev
[[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]] && source /opt/dev/dev.sh

# Tec agent (Shopify Nix)
[[ -x ~/.local/state/tec/profiles/base/current/global/init ]] && [[ $- == *i* ]] && \
    eval "$(~/.local/state/tec/profiles/base/current/global/init zsh)"

# Rust
if command -v rustup &>/dev/null; then
    source <(rustup completions zsh rustup 2>/dev/null)
    source <(rustup completions zsh cargo 2>/dev/null)
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
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
