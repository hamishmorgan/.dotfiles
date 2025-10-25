# shellcheck shell=bash
# ~/.bash_profile: executed by bash(1) for login shells.
# Environment variables and PATH configuration.
# See SHELL_CONFIG_GUIDE.md for detailed explanation of shell configuration files.

# Detect OS
BASH_HOST_OS=$(uname | awk '{print tolower($0)}')
export BASH_HOST_OS

# OS-specific PATH configuration
case $BASH_HOST_OS in
  darwin*)
    # GNU tools PATH for macOS (if installed via Homebrew)
    if command -v brew &> /dev/null; then
      PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
      PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
      MANPATH="$(brew --prefix coreutils)/libexec/gnuman:${MANPATH:-}"
      export PATH MANPATH
    fi
    ;;
esac

# User bin directories
export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

# Node Version Manager
export NVM_DIR="$HOME/.nvm"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
# shellcheck source=/dev/null
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# mise (polyglot runtime manager)
if command -v mise &> /dev/null; then
  eval "$(mise activate bash)"
fi

# Rust cargo environment
# shellcheck source=/dev/null
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Source bashrc for interactive shells
# shellcheck source=/dev/null
if [ -f "$HOME/.bashrc" ]; then
  . "$HOME/.bashrc"
fi

# Tec agent integration (conditional - safe on all machines)
if [[ -x ~/.local/state/tec/profiles/base/current/global/init ]]; then
  eval "$(~/.local/state/tec/profiles/base/current/global/init bash)"
fi

# Machine-specific configuration (not version-controlled)
if [ -f ~/.bash_profile.local ]; then
    source ~/.bash_profile.local
fi

