# Fish Package

Fish shell configuration with custom functions and platform-specific settings.

## Files Managed

- `.config/fish/config.fish` - Main fish configuration
- `.config/fish/config.osx.fish` - macOS-specific configuration
- `.config/fish/config.linux.fish` - Linux-specific configuration
- `.config/fish/functions/*.fish` - Custom functions
- `.config/fish/conf.d/*.fish` - Configuration snippets

## Features

- **Platform-specific configuration** - OS-detected automatic loading
- **Custom functions** - Enhanced commands and utilities
- **Tool integrations** - Automatic detection and configuration
- **Modern CLI tool support** - eza integration when installed
- **Custom prompt** - Enhanced fish_prompt with git status

## Installation

```bash
./dot enable fish

# Set as default shell (optional)
chsh -s $(which fish)
```

After changing default shell, log out and back in for changes to take effect.

## Configuration

```bash
nano ~/.config/fish/config_private.fish  # Machine-specific settings (git-ignored)
```

**Custom functions:** `d.fish` (dotfiles wrapper), `fish_prompt.fish` (custom prompt)

**Platform-specific:** Auto-sources `config.osx.fish` (macOS) or `config.linux.fish` (Linux)
