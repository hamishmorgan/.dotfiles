# shellcheck shell=zsh
# macOS-specific configuration

# Fallback OS detection if ZSH_HOST_OS not set
local os="${ZSH_HOST_OS:-$(uname | tr '[:upper:]' '[:lower:]')}"

case "$os" in
  darwin*)
    # macOS-specific configuration

    # Faster keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 1
    defaults write NSGlobalDomain InitialKeyRepeat -int 12

    # Show hidden files in finder
    defaults write com.apple.finder AppleShowAllFiles YES

    # Homebrew shellenv (if exists)
    [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    ;;
esac

