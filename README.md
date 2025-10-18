# .dotfiles

[![CI](https://github.com/hamishmorgan/.dotfiles/workflows/CI/badge.svg)](https://github.com/hamishmorgan/.dotfiles/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-3.2%2B-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)](#prerequisites)
[![GNU Stow](https://img.shields.io/badge/GNU-Stow-orange.svg)](https://www.gnu.org/software/stow/)
[![Shell](https://img.shields.io/github/languages/top/hamishmorgan/.dotfiles)](https://github.com/hamishmorgan/.dotfiles)

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

- Installation script with dependency checks
- Backup of existing files before installation
- Template-based secrets management
- macOS and Linux support
- Validation script for installation verification
- Packages: git, zsh, tmux, gh, gnuplot, bash
- Oh My Zsh submodule
- CI/CD validation with GitHub Actions

## Package Structure

```text
.dotfiles/
├── git/           # Git configuration and aliases
│   ├── .gitconfig.template      # Git config template
│   ├── .gitconfig.secret.example  # Secret config example
│   └── .gitconfig.secret      # Secret config (git-ignored)
├── zsh/           # Zsh configuration with Oh My Zsh
│   ├── .zshrc
│   ├── .zprofile
│   ├── .zshrc.osx
│   ├── .zshrc.linux
│   └── .oh-my-zsh/  # Oh My Zsh submodule
├── tmux/          # Tmux configuration
├── gh/            # GitHub CLI configuration
│   └── .config/gh/
│       ├── config.yml.template
│       ├── config.yml.secret.example
│       └── config.yml.secret   # Secret config (git-ignored)
├── gnuplot/       # GNU Plot configuration
├── bash/          # Bash configuration
│   ├── .bashrc
│   └── .bash_profile
├── dot            # Main dotfiles management script
└── README.md      # This file
```

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

The installer verifies dependencies, backs up existing files, initializes submodules, and creates symlinks.

## Optional: Set zsh as default shell

```bash
chsh -s $(which zsh)
```

Log out and back in for the change to take effect.

### Manual Installation

```bash
git clone git@github.com:hamishmorgan/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive
stow -v git zsh tmux gh gnuplot bash
```

**Note:** Manual installation still requires processing templates and merging secret configs.
Use `./dot install` for the complete installation process.

## Verification

Check installation status:

```bash
cd ~/.dotfiles
./dot status        # Quick overview (symlinks + backups)
./dot health        # Comprehensive diagnostics
```

### Health Check

The health check performs comprehensive diagnostics in a clean, scannable table format:

```bash
./dot health        # Table format (quick overview)
./dot health -v     # Verbose mode (detailed output)
```

The table format shows all checks at a glance with Pass/Fail/Warn status and identifies
maintenance items that need attention.

The health check performs 11 categories of checks:

1. **Symlink Integrity**: Verifies all configuration symlinks point to correct files
2. **Configuration Syntax**: Validates git, tmux, zsh, and bash configuration syntax
3. **Submodule Health**: Checks Oh My Zsh submodule status and initialization
4. **Git Repository Status**: Reports uncommitted changes, branch status, and sync with origin
5. **Template Configuration Consistency**: Detects missing secret configs and stale merged files
6. **File Permissions**: Ensures secret configs have secure permissions and aren't tracked by git
7. **Shell Integration**: Verifies shell configs are active and PATH is properly configured
8. **Stow Conflicts**: Detects unmanaged files that would conflict with stow
9. **Orphaned Symlinks**: Finds broken symlinks in home and .config directories
10. **Dependencies**: Checks all required tools are installed
11. **Backup Health**: Reports backup directory status and suggests cleanup if needed

## What gets installed

### Git (`git/`)

- Aliases and shortcuts
- Color configuration
- Diff tools for various file types
- Shopify-specific configuration

### Zsh (`zsh/`)

- Login shell environment (`.zprofile`)
- Interactive shell configuration (`.zshrc`)
- Oh My Zsh integration with plugins
- Platform-specific settings (`.zshrc.osx`, `.zshrc.linux`)
- Custom aliases and functions

### Tmux (`tmux/`)

- Custom key bindings (prefix: backtick)
- Mouse support
- Custom status bar
- Base index: 1

### GitHub CLI (`gh/`)

- GitHub CLI configuration and aliases

### GNU Plot (`gnuplot/`)

- Plotting configuration and styles
- Custom color schemes and terminal settings

### Bash (`bash/`)

- Login shell environment (`.bash_profile`)
- Interactive shell configuration (`.bashrc`)
- NVM, mise, and cargo integration
- Custom aliases

## Updating

### Update Global Gitignore

```bash
curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```

Or using the gi alias:

```bash
gi linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```

## Secret Configuration

This dotfiles setup uses a template-based approach for managing sensitive information.
Secret configurations are stored in separate files that are git-ignored.

### Setting Up Secret Configuration

1. **Git Configuration**:

   ```bash
   # Copy the example and customize
   cp ~/.dotfiles/git/.gitconfig.secret.example ~/.dotfiles/git/.gitconfig.secret
   
   # Edit with your personal information
   nano ~/.dotfiles/git/.gitconfig.secret
   ```

2. **GitHub CLI Configuration**:

   ```bash
   # Copy the example and customize
   cp ~/.dotfiles/gh/.config/gh/config.yml.secret.example ~/.dotfiles/gh/.config/gh/config.yml.secret
   
   # Edit with your personal preferences
   nano ~/.dotfiles/gh/.config/gh/config.yml.secret
   ```

3. **Reinstall to apply changes**:

   ```bash
   ./dot install
   ```

### Template System

- **Templates**: Public configuration files with placeholders (e.g., `YOUR_EMAIL_HERE`)
- **Secret Configs**: Private files with actual sensitive values (git-ignored)
- **Merged Configs**: Final configuration files created during installation

The installation script automatically:

1. Creates config files from templates
2. Merges secret configurations
3. Installs using Stow

### Update

```bash
cd ~/.dotfiles
git pull origin main
git submodule update --init --recursive
./dot install
```

## Uninstallation

### Uninstall

```bash
cd ~/.dotfiles
stow -D git zsh tmux gh gnuplot bash
# Restore from backup directories in ~/.dotfiles-backup-* if needed
```

## Troubleshooting

### Permission Errors

```bash
chmod +x dot
```

### Stow Conflicts

```bash
stow -v -R git zsh tmux gh gnuplot bash
```

Verify installation:

```bash
./dot health
```

## Linting

To ensure code quality, run linters:

### Linting Prerequisites

Install linting tools:

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install shellcheck
npm install -g markdownlint-cli
```

**macOS:**

```bash
brew install shellcheck
npm install -g markdownlint-cli
```

### Linting Commands

Markdown files:

```bash
markdownlint "**/*.md"
```

Bash scripts:

```bash
shellcheck dot
```

All files:

```bash
markdownlint "**/*.md" && shellcheck dot
```

## CI/CD

This repository includes GitHub Actions workflows for automated validation:

- **Linting**: Validates Markdown and Bash scripts before installation tests
- **Ubuntu Validation**: Tests full installation on Ubuntu with dependency checks
- **macOS Validation**: Tests full installation on macOS with dependency checks
- **Configuration Testing**: Validates git, zsh, and other package configurations

Workflow file: `.github/workflows/validate.yml`

## Development

1. Create feature branch
2. Make changes
3. Run linters: `markdownlint "**/*.md" && shellcheck dot`
4. Test with `./dot health`
5. Commit changes
