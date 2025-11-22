# shellcheck shell=zsh
# Linux-specific configuration

# Fallback OS detection if ZSH_HOST_OS not set
local os="${ZSH_HOST_OS:-$(uname | tr '[:upper:]' '[:lower:]')}"

case "$os" in
  linux*)
    # Linux-specific configuration
    # Currently empty, ready for future additions
    ;;
esac

