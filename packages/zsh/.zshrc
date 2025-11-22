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

# zoxide (smart cd replacement)
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
    alias zi='zoxide query -i'  # Interactive selection
fi

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

# gitignore.io (gi command)
gi() {
    local timeout="${DOTFILES_CURL_TIMEOUT:-30}"
    local url="https://www.toptal.com/developers/gitignore/api/$*"
    if curl -sLw "\n" --max-time "$timeout" "$url"; then
        return 0
    else
        echo "Error: Failed to fetch gitignore patterns (timeout or network error)" >&2
        return 1
    fi
}

# ━━━ Aliases ━━━

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# ━━━ Editor Configuration ━━━

# ━━━ Helper Functions ━━━

# Get process info from PID (command or args)
_get_process_info() {
    local pid="$1"
    local field="$2"

    if ! command -v ps &>/dev/null || [[ -z "$pid" ]]; then
        return 1
    fi

    local output
    output=$(ps -o "$field"= -p "$pid" 2>/dev/null)
    # Trim leading/trailing whitespace
    output="${output#"${output%%[![:space:]]*}"}"
    output="${output%"${output##*[![:space:]]}"}"
    if [[ -z "$output" ]]; then
        return 1
    fi

    echo "$output"
}

# Get parent PID from a given PID
_get_parent_pid() {
    local pid="$1"
    local parent_pid

    parent_pid=$(_get_process_info "$pid" ppid)
    # Stop at init (PID 1) or kernel processes (PID 0)
    if [[ -z "$parent_pid" ]] || [[ "$parent_pid" -le 1 ]]; then
        return 1
    fi

    echo "$parent_pid"
}

# Check if process matches pattern (checks both command and args)
_process_matches_pattern() {
    local pid="$1"
    local pattern="$2"
    local cmd
    local args

    cmd=$(_get_process_info "$pid" comm)
    args=$(_get_process_info "$pid" args)

    if [[ -n "$cmd" ]] && [[ "$cmd" == *"$pattern"* ]]; then
        return 0
    fi

    if [[ -n "$args" ]] && [[ "$args" == *"$pattern"* ]]; then
        return 0
    fi

    return 1
}

# Walk up process tree to find editor (handles nested shells)
# This is necessary because:
# - Shells can be nested (e.g., zsh inside tmux inside Cursor)
# - Only checking PPID misses editors that are further up the tree
# - Simple PPID check fails in nested scenarios
_find_editor_in_process_tree() {
    local pattern="$1"
    local max_depth="${2:-10}"
    local current_pid

    if [[ -z "${PPID:-}" ]]; then
        return 1
    fi

    current_pid="$$"

    # Check current process first
    if _process_matches_pattern "$current_pid" "$pattern"; then
        echo "$current_pid"
        return 0
    fi

    # Walk up the process tree
    local i
    for ((i = 0; i < max_depth; i++)); do
        local parent_pid
        parent_pid=$(_get_parent_pid "$current_pid")
        if [[ -z "$parent_pid" ]]; then
            return 1
        fi

        if _process_matches_pattern "$parent_pid" "$pattern"; then
            echo "$parent_pid"
            return 0
        fi

        current_pid="$parent_pid"
    done

    return 1
}

# Check if editor is in process tree
_is_editor_in_context() {
    local editor="$1"
    local pattern=""

    case "$editor" in
        cursor)
            # Check environment variables first
            if [[ -n "${CURSOR_INJECTION:-}" ]] || [[ "${TERM_PROGRAM:-}" == "cursor" ]]; then
                return 0
            fi
            pattern="cursor"
            ;;
        code)
            if [[ -n "${VSCODE_INJECTION:-}" ]] || [[ "${TERM_PROGRAM:-}" == "vscode" ]]; then
                return 0
            fi
            pattern="code"
            ;;
        nvim|vim)
            pattern="$editor"
            ;;
        *)
            return 1
            ;;
    esac

    # Fallback: check process tree
    local editor_pid
    editor_pid=$(_find_editor_in_process_tree "$pattern" 10)
    [[ -n "$editor_pid" ]]
}

# ━━━ Editor Detection ━━━

# Detect which editor context we're running in (priority: cursor, code, nvim, vim)
_detect_editor() {
    local editor
    for editor in cursor code nvim vim; do
        if _is_editor_in_context "$editor"; then
            echo "$editor"
            return 0
        fi
    done
    echo ""
}

# Check if editor is installed
_is_editor_installed() {
    local editor="$1"
    case "$editor" in
        cursor|code|nvim|vim|vi|nano)
            command -v "$editor" &>/dev/null
            ;;
        *)
            return 1
            ;;
    esac
}

# Find installed terminal editor in priority order
_find_terminal_editor() {
    local editor
    for editor in nvim vim vi nano; do
        if _is_editor_installed "$editor"; then
            echo "$editor"
            return 0
        fi
    done
    echo "vi"  # POSIX requires vi to exist (absolute final fallback after nano)
}

# Resolve editor command with arguments from context
_resolve_context_editor_command() {
    local context="$1"

    if [[ -z "$context" ]] || ! _is_editor_installed "$context"; then
        return 1
    fi

    case "$context" in
        cursor|code)
            # Note: --reuse-window flag doesn't work on Linux (Cursor bug)
            # Even with the flag, Cursor creates new windows instead of reusing existing ones
            # This is a known limitation of Cursor's Linux implementation
            echo "$context --wait"
            ;;
        *)
            echo "$context"
            ;;
    esac
}

# Find best visual editor (GUI preferred, then terminal)
_find_best_visual_editor() {
    if _is_editor_installed cursor; then
        # Note: --reuse-window flag doesn't work on Linux (Cursor bug)
        echo "cursor --wait"
    elif _is_editor_installed code; then
        # VSCode typically handles workspace detection better on Linux
        echo "code --wait"
    else
        _find_terminal_editor
    fi
}

# ━━━ Environment Setup ━━━

# Set VISUAL and EDITOR based on detected editor
# Accepts optional context parameter to avoid redundant detection (currently unused but kept for flexibility)
# shellcheck disable=SC2120  # Optional parameter is intentional for future use
_set_editor_env() {
    local context="${1:-}"
    if [[ -z "$context" ]]; then
        context=$(_detect_editor)
    fi

    # Priority 1: Use in-context editor for both if it exists
    local context_cmd
    context_cmd=$(_resolve_context_editor_command "$context" 2>/dev/null)
    if [[ -n "$context_cmd" ]]; then
        # Validate that the editor command is executable
        local editor_cmd
        editor_cmd="${context_cmd%% *}"  # Extract first word (command name)
        if command -v "$editor_cmd" &>/dev/null; then
            export VISUAL="$context_cmd"
            export EDITOR="$context_cmd"
            return
        fi
    fi

    # Priority 2: Set EDITOR to best terminal-compatible editor
    local terminal_editor
    terminal_editor=$(_find_terminal_editor)
    if [[ -n "$terminal_editor" ]]; then
        export EDITOR="$terminal_editor"
    fi

    # Priority 3: Set VISUAL to best visual option, fallback to EDITOR
    local visual_editor
    visual_editor=$(_find_best_visual_editor)
    export VISUAL="$visual_editor"
}

# Set editors based on context detection
# Always detect context and set appropriately, even if already set
# Context can change (e.g., switching between terminal and Cursor's integrated terminal)
# so we re-detect to ensure VISUAL/EDITOR match the current environment
# Use _set_editor_env to handle all context detection and environment variable setting
_set_editor_env

# GIT_EDITOR defaults to EDITOR
if [[ -z "${GIT_EDITOR:-}" ]]; then
    export GIT_EDITOR="$EDITOR"
fi

# ━━━ User Functions ━━━

# Edit file with EDITOR
# Handles EDITOR values that contain arguments (e.g., "cursor --wait")
# Uses eval to properly handle paths with spaces and complex commands
e() {
    local editor="${EDITOR:-}"

    # Fallback to terminal editor if EDITOR not set
    if [[ -z "$editor" ]]; then
        editor=$(_find_terminal_editor)
    fi

    # Validate editor command exists (extract command name, ignore args)
    local editor_cmd
    editor_cmd="${editor%% *}"  # Extract first word (command name)
    if ! command -v "$editor_cmd" &>/dev/null; then
        echo "Error: Editor command not found: $editor_cmd" >&2
        return 1
    fi

    # Use eval to properly handle EDITOR with arguments and paths containing spaces
    # This safely executes: editor_command editor_args user_args
    # shellcheck disable=SC2294  # eval is necessary to handle EDITOR with arguments (e.g., "cursor --wait")
    eval "$editor" "$@"
}

# Edit file with EDITOR (alias of e)
v() {
    e "$@"
}

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
