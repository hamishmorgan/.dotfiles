# shellcheck shell=bash
# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="bira" # set by `omz`

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git                    # Git aliases and functions
  docker                 # Docker aliases and functions (detected)
  docker-compose         # Docker Compose support
  gh                     # GitHub CLI support (detected)
  node                   # Node.js support (detected)
  nvm                    # Node Version Manager (detected)
  extract                # Archive extraction shortcuts
  colored-man-pages      # Colored man pages
  z                      # Smart directory jumping
  sudo                   # Double-tap ESC to add sudo
  fancy-ctrl-z           # Ctrl-Z to toggle fg/bg
  git-auto-fetch         # Auto-fetch git repos
  git-extras             # Additional git utilities
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# ls aliases - use eza if available, otherwise rely on Oh My Zsh defaults
if command -v eza &>/dev/null; then
  # eza (modern ls replacement) aliases
  alias ls='eza --icons --group-directories-first'
  alias ll='eza --long --header --icons --group-directories-first --git'
  alias la='eza --long --all --header --icons --group-directories-first --git'
  alias lt='eza --tree --level=2 --icons'
  alias lta='eza --tree --level=2 --all --icons'
  alias lg='eza --long --git --git-ignore --icons'
  alias lm='eza --long --sort=modified --reverse --icons'
  alias lz='eza --long --sort=size --reverse --icons'
fi

# Detect OS for conditional configuration loading
export ZSH_HOST_OS=$(uname | awk '{print tolower($0)}')

# Load configs for MacOS. Does nothing if not on MacOS
if [ "$ZSH_HOST_OS" = "darwin" ]; then
  source "$HOME/.zshrc.osx"
fi

# Load configs for Linux. Does nothing if not on Linux
if [ "$ZSH_HOST_OS" = "linux" ]; then
  source "$HOME/.zshrc.linux"
fi

# bat (modern cat replacement with syntax highlighting)
# Ubuntu/Debian name the binary 'batcat' to avoid conflict with bacula-console-qt
if command -v batcat &>/dev/null; then
    alias bat='batcat'
    export BAT_CONFIG_PATH="$HOME/.config/bat/config"
elif command -v bat &>/dev/null; then
    export BAT_CONFIG_PATH="$HOME/.config/bat/config"
fi
# Optional: Uncomment to replace cat with bat everywhere
# Note: This may break scripts that parse cat output
# alias cat='bat --paging=never'

# Load dotfiles management function and completions from dot script
if [ -f "$HOME/.dotfiles/dot" ]; then
    source <("$HOME/.dotfiles/dot" --completion zsh)
fi

# Shopify development environment (conditional - safe on all machines)
# dev.sh provides: chruby, nvm, PATH setup, autocomplete
if [[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]]; then
    source /opt/dev/dev.sh
fi

# Tec agent integration (Shopify's managed Nix environment)
# Note: eval is required - tec init outputs shell-specific code
if [[ -x ~/.local/state/tec/profiles/base/current/global/init ]] && [[ $- == *i* ]]; then
    eval "$(~/.local/state/tec/profiles/base/current/global/init zsh)"
fi

# Rust environment
if command -v rustup &>/dev/null; then
    source <(rustup completions zsh rustup)
    source <(rustup completions zsh cargo)
fi

if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# Machine-specific configuration (not version-controlled)
if [ -f ~/.zshrc.local ]; then
    source ~/.zshrc.local
fi

