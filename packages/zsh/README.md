# Zsh Package

Zsh shell configuration with native completion systems and platform-specific settings.

## Files Managed

- `.zshrc` - Interactive shell configuration
- `.zprofile` - Login shell environment
- `.zshrc.osx` - macOS-specific configuration (sourced from `.zshrc`)
- `.zshrc.linux` - Linux-specific configuration (sourced from `.zshrc`)

## Features

- **Login shell environment** (`.zprofile`) - Initial environment setup
- **Interactive configuration** (`.zshrc`) - Aliases, functions, completion
- **Native completion system** - Fast, built-in completions (no oh-my-zsh required)
- **Platform-specific settings** - OS-detected automatic sourcing
- **Custom aliases and functions** - Enhanced commands
- **Modern CLI tool support** - eza integration when installed

## Installation

```bash
./dot enable zsh

# Set as default shell (optional)
chsh -s $(which zsh)
```

After changing default shell, log out and back in for changes to take effect.

## Configuration

```bash
cp packages/zsh/.zshrc.local.example ~/.zshrc.local
nano ~/.zshrc.local
```

**Platform-specific:** Auto-sources `.zshrc.osx` (macOS) or `.zshrc.linux` (Linux)

**No frameworks:** Uses native zsh completion for faster startup and simpler configuration.
