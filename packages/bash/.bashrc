# shellcheck shell=bash
# Bash shell configuration
# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Detect OS (needed early for conditional loading)
export BASH_HOST_OS=$(uname | tr '[:upper:]' '[:lower:]')

# XDG Base Directory support
# Only set if not already set (allows re-sourcing without errors)
[[ -z "$BASH_CONFIG_DIR" ]] && readonly BASH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"

# Load modular configuration files
# Files are loaded in alphabetical order. If one file fails, others continue loading.
if [[ -d "$BASH_CONFIG_DIR/conf.d" ]]; then
  for config_file in "$BASH_CONFIG_DIR/conf.d"/*.bash; do
    if [[ -f "$config_file" ]] && [[ -r "$config_file" ]]; then
      # Source with error handling - continue loading other files if one fails
      if ! source "$config_file" 2>/dev/null; then
        # Only show error if BASH_DEBUG is set (for debugging)
        [[ -n "${BASH_DEBUG:-}" ]] && echo "Warning: Failed to load $(basename "$config_file")" >&2
      fi
    fi
  done
fi

# Load custom functions
if [[ -d "$BASH_CONFIG_DIR/functions" ]]; then
  for func_file in "$BASH_CONFIG_DIR/functions"/*.bash; do
    if [[ -f "$func_file" ]] && [[ -r "$func_file" ]]; then
      if ! source "$func_file" 2>/dev/null; then
        [[ -n "${BASH_DEBUG:-}" ]] && echo "Warning: Failed to load function $(basename "$func_file")" >&2
      fi
    fi
  done
fi

# Machine-specific configuration (git-ignored, user-created)
# Users can create any .bash file in ~/.config/bash/conf.d/ for machine-specific configs
# All .bash files in conf.d/ are automatically loaded (including user-created ones)

# Backward compatibility: also check old location
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

# Local bin environment (if exists)
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
