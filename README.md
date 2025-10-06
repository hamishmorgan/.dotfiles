# .dotfiles

[![CI](https://github.com/hamishmorgan/.dotfiles/workflows/CI/badge.svg)](https://github.com/hamishmorgan/.dotfiles/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Bash-4.0%2B-green.svg)](https://www.gnu.org/software/bash/)
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
│   ├── .gitconfig.personal.example  # Personal config example
│   └── .gitconfig.personal      # Personal config (git-ignored)
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
│       ├── config.yml.personal.example
│       └── config.yml.personal   # Personal config (git-ignored)
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
# Note: bash 4.0+ is required (macOS ships with bash 3.2)
brew install stow git tmux zsh bash
```

**Important:** macOS ships with bash 3.2. This script requires bash 4.0+ for associative array support.
After installing, run the script with: `/opt/homebrew/bin/bash ./dot install`

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

**macOS users:** If you get an error about bash version, use homebrew bash:

```bash
/opt/homebrew/bin/bash ./dot install
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

**Note:** Manual installation still requires processing templates and merging personal configs.
Use `./dot install` for the complete installation process.

## Validation

Validate installation:

```bash
cd ~/.dotfiles
./dot validate
```

Verifies symlink integrity, configuration validity, dependencies, and orphaned symlinks.

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

## Personal Configuration

This dotfiles setup uses a template-based approach for managing sensitive information.
Personal configurations are stored in separate files that are git-ignored.

### Setting Up Personal Configuration

1. **Git Configuration**:

   ```bash
   # Copy the example and customize
   cp ~/.dotfiles/git/.gitconfig.personal.example ~/.dotfiles/git/.gitconfig.personal
   
   # Edit with your personal information
   nano ~/.dotfiles/git/.gitconfig.personal
   ```

2. **GitHub CLI Configuration**:

   ```bash
   # Copy the example and customize
   cp ~/.dotfiles/gh/.config/gh/config.yml.personal.example ~/.dotfiles/gh/.config/gh/config.yml.personal
   
   # Edit with your personal preferences
   nano ~/.dotfiles/gh/.config/gh/config.yml.personal
   ```

3. **Reinstall to apply changes**:

   ```bash
   ./dot install
   ```

### Template System

- **Templates**: Public configuration files with placeholders (e.g., `YOUR_EMAIL_HERE`)
- **Personal Configs**: Private files with actual values (git-ignored)
- **Merged Configs**: Final configuration files created during installation

The installation script automatically:

1. Creates config files from templates
2. Merges personal configurations
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

### Bash Version Error (macOS)

If you see `declare: -A: invalid option`:

```bash
# macOS ships with bash 3.2, script requires 4.0+
brew install bash

# Run with homebrew bash
/opt/homebrew/bin/bash ./dot install
```

### Permission Errors

```bash
chmod +x dot
```

### Stow Conflicts

```bash
stow -v -R git zsh tmux gh gnuplot bash
```

Validation:

```bash
./dot validate
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
4. Test with `./dot validate`
5. Commit changes
