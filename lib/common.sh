#!/usr/bin/env bash
# Common constants, globals, and utility functions
# Compatible with bash 3.2+

# Check bash version meets minimum requirement (3.2+)
# Exits with error if version is too old
check_bash_version() {
    if [[ "${BASH_VERSINFO[0]}" -lt 3 || ( "${BASH_VERSINFO[0]}" -eq 3 && "${BASH_VERSINFO[1]}" -lt 2 ) ]]; then
        echo "Error: This script requires bash 3.2 or later"
        echo "Current version: $BASH_VERSION"
        exit 1
    fi
}

# Verify bash version (called immediately)
check_bash_version

# Safer glob handling
shopt -s nullglob      # Empty expansion for non-matching globs
shopt -s extglob       # Extended pattern matching

# Note: Not using 'set -e' for better error handling control
# Errors are explicitly checked and handled with context

# Configuration
# Note: DOTFILES_DIR must be set before sourcing this file
# readonly PACKAGES_DIR="$DOTFILES_DIR/packages"

# Backup retention policy (configurable via environment variables)
readonly MAX_BACKUPS_TO_DISPLAY="${DOTFILES_MAX_BACKUPS_TO_DISPLAY:-5}"     # Status output
readonly MAX_BACKUPS_TO_KEEP="${DOTFILES_MAX_BACKUPS_TO_KEEP:-10}"          # Auto cleanup threshold

# Display limits
readonly RESTORE_DISPLAY_LIMIT="${DOTFILES_RESTORE_DISPLAY_LIMIT:-20}"      # Restore preview

# Timeout values in seconds
readonly GIT_TIMEOUT="${DOTFILES_GIT_TIMEOUT:-60}"                           # Git operations
readonly CURL_TIMEOUT="${DOTFILES_CURL_TIMEOUT:-30}"                         # Curl downloads

# Security
readonly SECRET_FILE_MODE="${DOTFILES_SECRET_FILE_MODE:-600}"                # Secret file permissions

# Backup paths
readonly BACKUP_DIR_PREFIX="${DOTFILES_BACKUP_DIR_PREFIX:-backups/dotfiles-backup}"
readonly RESTORE_SAFETY_PREFIX="${DOTFILES_RESTORE_SAFETY_PREFIX:-backups/dotfiles-pre-restore}"
# BACKUP_DIR is set dynamically in main script

# Unit conversion constants
readonly SECONDS_PER_DAY=86400
readonly KB_TO_MB=1024

# Track installation state for rollback
INSTALLED_PACKAGES=()
INSTALLATION_IN_PROGRESS=false
ROLLBACK_STACK=()

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Portable timeout function (works on Linux and macOS)
# Uses GNU timeout if available, otherwise falls back to Perl
portable_timeout() {
    local duration="$1"
    shift

    if command_exists timeout; then
        timeout "$duration" "$@"
    elif command_exists perl; then
        # Perl-based timeout (portable, available on macOS)
        perl -e 'alarm shift; exec @ARGV' "$duration" "$@"
    else
        # No timeout available, run command normally
        "$@"
    fi
}

# Detect platform
detect_platform() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    else
        echo "unknown"
    fi
}

