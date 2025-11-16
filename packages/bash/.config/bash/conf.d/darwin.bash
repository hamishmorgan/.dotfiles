# shellcheck shell=bash
# macOS-specific bash configuration

case $BASH_HOST_OS in
	darwin*)
		# Homebrew shell environment
		[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
	;;
esac

# Note: System settings (keyboard repeat, finder) should be configured once via:
# - System Preferences
# - A one-time setup script
# - Not in shell config (runs on every shell startup)

