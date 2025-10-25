# shellcheck shell=bash
# ~/.zprofile: executed by zsh(1) for login shells.
# Environment variables and PATH configuration.
# See SHELL_CONFIG_GUIDE.md for detailed explanation of shell configuration files.

# OS-specific PATH configuration (ZSH_HOST_OS is set in .zshrc)
case ${ZSH_HOST_OS:-$(uname | awk '{print tolower($0)}')} in
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

# mise (polyglot runtime manager)
if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
fi

# Rust cargo environment
# shellcheck source=/dev/null
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Machine-specific configuration (not version-controlled)
if [ -f ~/.zprofile.local ]; then
    source ~/.zprofile.local
fi

