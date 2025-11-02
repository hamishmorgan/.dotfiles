# Bash Package

Bash shell configuration with tool integrations and platform-specific settings.

## Files Managed

- `.bashrc` - Interactive shell configuration
- `.bash_profile` - Login shell environment
- `.bashrc.osx` - macOS-specific configuration (sourced from `.bashrc`)
- `.bashrc.linux` - Linux-specific configuration (sourced from `.bashrc`)

## Features

- **Login shell environment** (`.bash_profile`) - Sets up initial environment
- **Interactive shell configuration** (`.bashrc`) - Aliases, functions, prompt
- **Tool integrations** - NVM, mise, cargo/rust
- **Custom aliases** - Enhanced commands and shortcuts
- **Platform detection** - Automatically sources OS-specific configs
- **Modern CLI tool support** - eza integration when installed

## Installation

```bash
./dot enable bash
```

## Configuration

```bash
cp packages/bash/.bashrc.local.example ~/.bashrc.local
nano ~/.bashrc.local
```

**Platform-specific:** Auto-sources `.bashrc.osx` (macOS) or `.bashrc.linux` (Linux)

**Tool integrations:** NVM, mise, cargo, eza (auto-detected)
