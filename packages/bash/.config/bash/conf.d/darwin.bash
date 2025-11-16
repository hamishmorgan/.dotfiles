# shellcheck shell=bash
# macOS-specific bash configuration

case $BASH_HOST_OS in
	darwin*)
		# macOS-specific configuration

		# Faster keyboard repeat rate
		defaults write NSGlobalDomain KeyRepeat -int 1
		defaults write NSGlobalDomain InitialKeyRepeat -int 12

		# Show hidden files in finder
		defaults write com.apple.finder AppleShowAllFiles YES

		[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
	;;
esac

