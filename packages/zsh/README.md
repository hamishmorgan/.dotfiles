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

## Machine-Specific Configuration

Create `~/.zshrc.local` for per-machine settings:

```bash
cp packages/zsh/.zshrc.local.example ~/.zshrc.local
nano ~/.zshrc.local
```

**Common uses:**
- Machine-specific aliases
- Private environment variables
- Work vs. personal customizations
- Tool-specific configuration

## Platform-Specific Behavior

The configuration automatically detects the platform and sources:
- `.zshrc.osx` on macOS
- `.zshrc.linux` on Linux

## What Makes This Different

**No framework dependencies:** Uses zsh's native completion system instead of oh-my-zsh or prezto for:
- Faster startup time
- Lower maintenance overhead
- Built-in features only
- Simpler configuration

