# .dotfiles

[![CI](https://github.com/hamishmorgan/.dotfiles/workflows/CI/badge.svg)](https://github.com/hamishmorgan/.dotfiles/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-3.2%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)](#prerequisites)
[![GNU Stow](https://img.shields.io/badge/GNU-Stow-orange.svg)](https://www.gnu.org/software/stow/)
[![Shell](https://img.shields.io/github/languages/top/hamishmorgan/.dotfiles)](https://github.com/hamishmorgan/.dotfiles)

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Table of Contents

- [Why This Dotfiles Setup?](#why-this-dotfiles-setup)
- [Quick Reference](#quick-reference)
- [Packages](#packages)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Optional Enhancements](#optional-enhancements)
- [Verification](#verification)
- [Machine-Specific Configuration](#machine-specific-configuration)
- [Updating](#updating)
- [Package Management](#package-management)
- [Advanced](#advanced)
- [Development](#development)
- [Contributing](#contributing)

## Why This Dotfiles Setup?

- **Safe installation** - Automatic backups before any changes, with rollback on failure
- **Machine-specific support** - Use `.local` files for per-machine customization without branches
- **Cross-platform** - Tested on macOS, Ubuntu, and Alpine (BSD-like)
- **Package-based** - Enable/disable individual configurations as needed
- **Health monitoring** - Comprehensive diagnostics to verify installation integrity
- **Standard tooling** - Uses GNU Stow (not custom solution), Bash 3.2 compatible

## Contents

- Installation script with dependency checks
- Backup of existing files before installation
- Template-based secrets management
- macOS and Linux support
- Health check system for diagnostics and validation
- Packages: system, git, bash, zsh, fish, tmux, gh, gnuplot, wezterm, bat, rust, cursor
- CI/CD validation with GitHub Actions

## Compatibility

- **Bash 3.2+**: Works with macOS default bash (no Homebrew bash needed)
- **Cross-platform**: Tested on Ubuntu, Alpine, and macOS
- **Bash 3.2 verified**: Explicitly tested in CI to ensure compatibility

The `dot` script is compatible with Bash 3.2, ensuring it works seamlessly with macOS's default
bash installation without requiring Homebrew bash. This compatibility is enforced through automated
testing on all platforms, including explicit Bash 3.2 validation in CI.

## Quick Reference

### Common Commands

```bash
./dot install          # Install all dotfiles
./dot update           # Update and reinstall
./dot status           # Show status
./dot health           # Run diagnostics
./dot packages         # List all packages
./dot enable rust      # Enable a package
./dot disable fish     # Disable a package
```

### Documentation

- **[COMMANDS.md](COMMANDS.md)** - Complete command reference
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[DEVELOPMENT.md](DEVELOPMENT.md)** - Developer documentation

### Quick Links

- [Installation](#installation) - Get started in 3 commands
- [Configuration](#configuration) - Environment variables
- [Machine-Specific Configuration](#machine-specific-configuration) - Per-machine settings
- [Package Management](#package-management) - Enable/disable packages
- [Advanced](#advanced) - Manual stow management

## Packages

All configurations are organized as packages in the `packages/` directory:

| Package | Description |
|---------|-------------|
| **system** | System-wide ignore patterns |
| **git** | Git configuration and aliases |
| **bash** | Bash shell configuration |
| **zsh** | Zsh shell configuration |
| **fish** | Fish shell configuration |
| **tmux** | Terminal multiplexer |
| **gh** | GitHub CLI configuration |
| **gnuplot** | GNU Plot configuration |
| **wezterm** | WezTerm terminal emulator |
| **bat** | Bat syntax highlighter |
| **rust** | Rust toolchain configuration |
| **cursor** | Cursor IDE (uses copy-sync) |

Each package has:

- `manifest.toml` - Defines managed files, installation method, and validation rules
- `README.md` - Package-specific documentation and configuration guide

See individual package README files for detailed configuration options and usage.

## Prerequisites

### macOS

```bash
# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install stow git tmux zsh
```

The `dot` script works with macOS's default bash 3.2, so no additional bash installation is needed.

### Linux

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install stow git tmux zsh

# CentOS/RHEL/Fedora
sudo yum install stow git tmux zsh
# or
sudo dnf install stow git tmux zsh
```

## Installation

```bash
git clone git@github.com:hamishmorgan/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./dot install
```

The installer verifies dependencies, backs up existing files, and creates symlinks. Add `-v` for verbose
or `-vv` for very verbose output.

## Configuration

Environment variables for customization:

| Variable | Default | Purpose |
|----------|---------|---------|
| `DOTFILES_MAX_BACKUPS_TO_KEEP` | 10 | Backup retention limit |
| `DOTFILES_MAX_BACKUPS_TO_DISPLAY` | 5 | Backups shown in status |
| `DOTFILES_RESTORE_DISPLAY_LIMIT` | 20 | Files shown in restore preview |
| `DOTFILES_GIT_TIMEOUT` | 60 | Git operation timeout (seconds) |
| `DOTFILES_CURL_TIMEOUT` | 30 | Curl timeout (seconds) |
| `DOTFILES_SECRET_FILE_MODE` | 600 | Secret file permissions |
| `DOTFILES_OUTPUT_PREFIX` | │ | Output indentation character |
| `DOTFILES_BACKUP_DIR_PREFIX` | backups/dotfiles-backup | Backup directory prefix |
| `DOTFILES_RESTORE_SAFETY_PREFIX` | backups/dotfiles-pre-restore | Restore safety prefix |

**Examples:**

```bash
# Keep more backups
DOTFILES_MAX_BACKUPS_TO_KEEP=20 ./dot install

# Longer timeout for slow networks
DOTFILES_GIT_TIMEOUT=120 ./dot install

# Plain ASCII output for CI/logs
DOTFILES_OUTPUT_PREFIX="| " ./dot install
```

## Optional Enhancements

### Git Delta - Enhanced Diff Viewer

[Git-delta](https://github.com/dandavison/delta) provides syntax-highlighted diffs with side-by-side view.

```bash
# Install delta
brew install git-delta  # macOS
cargo install git-delta # Other platforms

# Enable in ~/.gitconfig.local
echo '[include]
    path = ~/.gitconfig.delta' >> ~/.gitconfig.local
```

See [packages/git/README.md](packages/git/README.md) for detailed git-delta configuration.

### Set Default Shell

```bash
# Zsh
chsh -s $(which zsh)

# Fish
chsh -s $(which fish)

# Bash (if using Homebrew bash)
chsh -s /opt/homebrew/bin/bash
```

Log out and back in for changes to take effect.

### Modern CLI Tools

The dotfiles include optional integrations for modern CLI tools. These tools are detected automatically and
aliases are configured if installed.

#### eza (modern ls replacement)

[eza](https://github.com/eza-community/eza) - Modern `ls` with icons, git integration, and tree views.

```bash
brew install eza      # macOS
cargo install eza     # Other platforms
```

**Auto-configured aliases:** `ls`, `ll`, `la`, `lt`, `lta`, `lg`, `lm`, `lz` (falls back to standard `ls` if eza not installed)

#### gitignore.io (gi command)

The `gi` command generates `.gitignore` files from [gitignore.io](https://gitignore.io) templates.
Available in bash, zsh, and fish shells.

```bash
# Generate gitignore for Python
gi python > .gitignore

# Generate gitignore for multiple types
gi node,osx,vim > .gitignore

# Append to existing gitignore
gi python >> .gitignore
```

**Configuration:** Uses `DOTFILES_CURL_TIMEOUT` environment variable (default: 30 seconds) for network timeouts.

## Verification

```bash
./dot status    # Quick overview
./dot health    # Comprehensive diagnostics (9 checks: symlinks, syntax, git, permissions, shell, conflicts, dependencies, backups)
```

See [COMMANDS.md](COMMANDS.md) for detailed command documentation.

## Machine-Specific Configuration

This dotfiles setup supports machine-specific configurations through `.local` files. These files are
git-ignored and allow you to customize settings per machine without affecting the shared configuration.

**Setup `.local` files:**

```bash
# Git (required - name, email, signing)
cp packages/git/.gitconfig.local.example ~/.gitconfig.local
nano ~/.gitconfig.local

# Shells (optional - machine-specific aliases, env vars, paths)
cp packages/bash/.bashrc.local.example ~/.bashrc.local
cp packages/zsh/.zshrc.local.example ~/.zshrc.local
nano ~/.config/fish/config_private.fish  # Fish uses different name
```

**Use cases:** Private API keys, work vs personal customizations, machine-specific tool paths, signing
configuration.

**Auto-appending tools:** Some tools (Shopify dev, tec agent) append to configs. Use `git add -p` to
skip duplicates when committing.

## Updating

```bash
./dot update    # Updates gitignore patterns, runs package updates, reinstalls
```

## Package Management

Manage individual packages after installation:

```bash
./dot packages         # List all packages with status
./dot enable rust      # Enable a package
./dot disable fish     # Disable a package
```

**Copy-sync packages:** The `cursor` package uses copy-sync instead of symlinks. Use `./dot sync cursor`
to sync settings to Cursor and `./dot pull cursor` to pull changes back.

See [COMMANDS.md](COMMANDS.md) for complete command documentation.

## Advanced

**Manual stow management:**

```bash
# Install
stow --verbose --restow --dir=packages --target=$HOME system git zsh bash fish tmux

# Uninstall  
stow --verbose --delete --dir=packages --target=$HOME system git zsh bash fish tmux
```

**Troubleshooting:** Run `./dot health -v` for diagnostics. See [COMMANDS.md](COMMANDS.md) for all commands.

## Development

```bash
./dev/setup              # Setup environment
./dev/lint && ./dev/test # Before commit
./dev/check              # Before push (complete validation)
```

See [CONTRIBUTING.md](CONTRIBUTING.md) and [DEVELOPMENT.md](DEVELOPMENT.md) for comprehensive developer documentation.

## Disk Cleanup Utility

Developer cache cleanup tool: `./bin/disk-cleanup`

```bash
./bin/disk-cleanup                      # Interactive
./bin/disk-cleanup --yes                # Non-interactive (safe)
./bin/disk-cleanup --yes --aggressive   # Aggressive cleanup
```

**Cleans:** 25+ tools (Homebrew, npm, Docker, Git, gems, pip, etc.) across 7 categories.
See [bin/README.md](bin/README.md) for complete documentation.

## Contributing

**Quick start:**

```bash
git clone git@github.com:YOUR_USERNAME/.dotfiles.git ~/.dotfiles
./dev/setup
./dev/lint && ./dev/test
gh pr create
```

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines including adding packages,
fixing bugs with TDD, and code standards. See [DEVELOPMENT.md](DEVELOPMENT.md) for architecture and
[COMMANDS.md](COMMANDS.md) for command reference.
