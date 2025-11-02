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

## Machine-Specific Configuration

Fish uses `config_private.fish` for machine-specific settings:

```bash
nano ~/.config/fish/config_private.fish
```

This file is git-ignored and sourced automatically from `config.fish`.

**Common uses:**

- Machine-specific environment variables
- Private API keys
- Work vs. personal aliases
- Tool-specific paths

## Custom Functions

Included functions in `.config/fish/functions/`:

- `d.fish` - Dotfiles wrapper with shortcuts
- `fish_prompt.fish` - Custom prompt with git integration

## Platform-Specific Behavior

The configuration automatically detects the platform and sources:

- `config.osx.fish` on macOS
- `config.linux.fish` on Linux

## What Makes This Different

**User-friendly shell:** Fish provides excellent defaults out of the box. This configuration enhances it with:

- Dotfiles integration (`d` command wrapper)
- Tool auto-detection
- Platform-specific optimizations
