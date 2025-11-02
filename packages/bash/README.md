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

## Machine-Specific Configuration

Create `~/.bashrc.local` for per-machine settings:

```bash
cp packages/bash/.bashrc.local.example ~/.bashrc.local
nano ~/.bashrc.local
```

**Common uses:**

- Machine-specific aliases
- Private environment variables
- Work vs. personal customizations
- Tool-specific paths

## Platform-Specific Behavior

The configuration automatically detects the platform and sources:

- `.bashrc.osx` on macOS
- `.bashrc.linux` on Linux

## Tool Integrations

Automatically configured when tools are installed:

- **NVM** - Node version manager
- **mise** - Polyglot runtime manager
- **cargo** - Rust package manager
- **eza** - Modern ls replacement (falls back to ls if not installed)
