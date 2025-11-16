# shellcheck shell=bash
# Bash shell configuration
# ~/.bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Detect OS (needed early for conditional loading)
export BASH_HOST_OS=$(uname | tr '[:upper:]' '[:lower:]')

# XDG Base Directory support
readonly BASH_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/bash"

# Load modular configuration files
if [[ -d "$BASH_CONFIG_DIR/conf.d" ]]; then
  for config_file in "$BASH_CONFIG_DIR/conf.d"/*.bash; do
    [[ -f "$config_file" ]] && [[ -r "$config_file" ]] && source "$config_file"
  done
fi

# Load custom functions
if [[ -d "$BASH_CONFIG_DIR/functions" ]]; then
  for func_file in "$BASH_CONFIG_DIR/functions"/*.bash; do
    [[ -f "$func_file" ]] && [[ -r "$func_file" ]] && source "$func_file"
  done
fi

# Machine-specific configuration (git-ignored, user-created)
# Users can create any .bash file in ~/.config/bash/conf.d/ for machine-specific configs
# All .bash files in conf.d/ are automatically loaded (including user-created ones)

# Backward compatibility: also check old location
[[ -f ~/.bashrc.local ]] && source ~/.bashrc.local

# Local bin environment (if exists)
[[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
