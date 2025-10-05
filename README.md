# .dotfiles

Dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

- Installation script with dependency checks
- Backup of existing files before installation
- macOS and Linux support
- Validation script for installation verification
- Packages: git, zsh, tmux
- Oh My Zsh submodule

## Package Structure

```text
.dotfiles/
├── git/           # Git configuration and aliases
├── zsh/           # Zsh configuration with Oh My Zsh
│   ├── .zshrc
│   ├── .zshrc.osx
│   └── .oh-my-zsh/  # Oh My Zsh submodule
├── tmux/          # Tmux configuration
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
stow -v git zsh tmux
```

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

- Oh My Zsh integration
- Platform-specific settings
- Custom aliases and functions
- History configuration

### Tmux (`tmux/`)

- Custom key bindings (prefix: backtick)
- Mouse support
- Custom status bar
- Base index: 1

## Updating

### Update Global Gitignore

```bash
curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```

Or using the gi alias:

```bash
gi linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```

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
stow -D git zsh tmux
# Restore from backup directories in ~/.dotfiles-backup-* if needed
```

## Troubleshooting

Permission errors:

```bash
chmod +x dot
```

Stow conflicts:

```bash
stow -v -R git zsh tmux
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

## Development

1. Create feature branch
2. Make changes
3. Run linters: `markdownlint "**/*.md" && shellcheck dot`
4. Test with `./dot validate`
5. Commit changes
