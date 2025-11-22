# shellcheck shell=bash
# shellcheck disable=SC2296
# SC2296: Zsh parameter expansion syntax
# Zsh shell configuration
# ~/.config/zsh/.zshrc

# If not running interactively, don't do anything
[[ -o interactive ]] || return

# OS detection (needed early for platform-specific files)
export ZSH_HOST_OS=$(uname | tr '[:upper:]' '[:lower:]')

# XDG Base Directory support (already set by ZDOTDIR, but explicit for clarity)
readonly ZSH_CONFIG_DIR="${ZDOTDIR:-${XDG_CONFIG_HOME:-$HOME/.config}/zsh}"

# Load modular configuration files
# Files are loaded in alphabetical order. If one file fails, others continue loading.
if [[ -d "$ZSH_CONFIG_DIR/conf.d" ]]; then
  for config_file in "$ZSH_CONFIG_DIR/conf.d"/*.zsh; do
    if [[ -f "$config_file" ]] && [[ -r "$config_file" ]]; then
      # Source with error handling - continue loading other files if one fails
      if [[ -n "${ZSH_DEBUG:-}" ]]; then
        # Show actual error when debugging
        if ! source "$config_file"; then
          echo "Warning: Failed to load $(basename "$config_file")" >&2
        fi
      else
        # Suppress errors in normal operation
        source "$config_file" 2>/dev/null || true
      fi
    fi
  done
fi

# Load custom functions
if [[ -d "$ZSH_CONFIG_DIR/functions" ]]; then
  for func_file in "$ZSH_CONFIG_DIR/functions"/*.zsh; do
    if [[ -f "$func_file" ]] && [[ -r "$func_file" ]]; then
      if [[ -n "${ZSH_DEBUG:-}" ]]; then
        if ! source "$func_file"; then
          echo "Warning: Failed to load function $(basename "$func_file")" >&2
        fi
      else
        source "$func_file" 2>/dev/null || true
      fi
    fi
  done
fi

# Machine-specific configuration (git-ignored, user-created)
# Users can create any .zsh file in ~/.config/zsh/conf.d/ for machine-specific configs
# All .zsh files in conf.d/ are automatically loaded (including user-created ones)

# Backward compatibility: also check old location
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local

# Local bin environment (if exists)
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"

