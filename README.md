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
- Packages: git, zsh, tmux, gh, gnuplot, bash, fish
- Oh My Zsh submodule
- CI/CD validation with GitHub Actions

## Compatibility

- **Bash 3.2+**: Works with macOS default bash (no Homebrew bash needed)
- **Cross-platform**: Tested on Ubuntu, Alpine, and macOS
- **Bash 3.2 verified**: Explicitly tested in CI to ensure compatibility

The `dot` script is compatible with Bash 3.2, ensuring it works seamlessly with macOS's default
bash installation without requiring Homebrew bash. This compatibility is enforced through automated
testing on all platforms, including explicit Bash 3.2 validation in CI.

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
├── fish/          # Fish shell configuration
│   └── .config/fish/
│       ├── config.fish
│       ├── config.linux.fish
│       ├── config.osx.fish
│       └── functions/
│           ├── d.fish           # Dotfiles wrapper function
│           └── fish_prompt.fish # Custom prompt
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

### Verbosity Levels

The `install` and `update` commands support multiple verbosity levels:

```bash
./dot install       # Clean summary (shows completion + errors/warnings)
./dot install -v    # Show package names and progress details
./dot install -vv   # Show every file symlinked (full detail)
```

Verbosity flags can be stacked:

```bash
./dot install -v -v              # Same as -vv
./dot install --verbose --verbose  # Same as -vv
```

**Verbosity Level Guide:**

- **Level 0** (default): Task completion summary with errors/warnings only
- **Level 1** (`-v`): Add package names and key progress steps
- **Level 2** (`-vv`): Show every file operation (symlinks, checks, etc.)

## Configuration

Customize behavior via environment variables:

### Display & Retention

- `DOTFILES_MAX_BACKUPS_TO_DISPLAY` - Backups shown in status output (default: 5)
- `DOTFILES_MAX_BACKUPS_TO_KEEP` - Maximum backups retained (default: 10)
- `DOTFILES_RESTORE_DISPLAY_LIMIT` - Files shown in restore preview (default: 20)

### Timeout Values (seconds)

- `DOTFILES_GIT_TIMEOUT` - Git operations timeout (default: 60)
- `DOTFILES_CURL_TIMEOUT` - Curl operations timeout (default: 30)

### Examples

```bash
# Show more backups in status
DOTFILES_MAX_BACKUPS_TO_DISPLAY=15 ./dot status

# Keep more backups
DOTFILES_MAX_BACKUPS_TO_KEEP=20 ./dot install

# Longer timeout for slow networks
DOTFILES_GIT_TIMEOUT=120 ./dot install

# Fast timeouts for CI
DOTFILES_GIT_TIMEOUT=30 DOTFILES_CURL_TIMEOUT=15 ./dot install

# Preview more files during restore
DOTFILES_RESTORE_DISPLAY_LIMIT=50 ./dot restore
```

## Optional: Set zsh as default shell

```bash
chsh -s $(which zsh)
```

Log out and back in for the change to take effect.

### Manual Installation

The `dot` script is optional. These dotfiles are standard GNU Stow packages and can be managed manually.

#### 1. Clone Repository

```bash
git clone git@github.com:hamishmorgan/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive
```

#### 2. Create Secret Files

Create personal configuration files (git-ignored):

**Git configuration:**

```bash
cp git/.gitconfig.secret.example git/.gitconfig.secret
# Edit with your information:
# - name, email, GitHub username
nano git/.gitconfig.secret
```

**GitHub CLI configuration:**

```bash
cp gh/.config/gh/config.yml.secret.example gh/.config/gh/config.yml.secret
# Edit with your preferences
nano gh/.config/gh/config.yml.secret
```

#### 3. Process Templates

Merge templates with secret configs:

```bash
# Git configuration
cat git/.gitconfig.template git/.gitconfig.secret > git/.gitconfig

# GitHub CLI configuration (if using gh)
cat gh/.config/gh/config.yml.template gh/.config/gh/config.yml.secret > gh/.config/gh/config.yml
```

#### 4. Install Packages with Stow

```bash
# Install system package first (provides .stow-global-ignore)
stow --verbose --restow --dir=. --target=$HOME system

# Install other packages
stow --verbose --restow --dir=. --target=$HOME git zsh tmux gh gnuplot bash

# Or install selectively
stow --verbose --restow --dir=. --target=$HOME git zsh
```

**What Stow does:**

- Creates symlinks from `~/.dotfiles/PACKAGE/FILE` to `~/FILE`
- Example: `~/.dotfiles/git/.gitconfig` → `~/.gitconfig`
- Handles nested directory structures automatically

#### 5. Verify Installation

```bash
# Check symlinks were created
ls -la ~ | grep "^l"

# Should show:
# lrwxr-xr-x .gitconfig -> .dotfiles/git/.gitconfig
# lrwxr-xr-x .zshrc -> .dotfiles/zsh/.zshrc

# Test configurations
git config --get user.name
git config --get user.email
```

#### Manual Update

```bash
cd ~/.dotfiles

# Pull latest changes
git pull origin main

# Update submodules
git submodule update --remote --merge

# Reinstall packages (picks up changes)
stow --verbose --restow --dir=. --target=$HOME git zsh tmux gh gnuplot bash
```

#### Manual Uninstall

```bash
cd ~/.dotfiles

# Remove all symlinks
stow --verbose --delete --dir=. --target=$HOME system git zsh tmux gh gnuplot bash

# Or remove specific packages
stow --verbose --delete --dir=. --target=$HOME git
```

**When to use manual installation:**

- You want full control over each step
- You're learning how Stow works
- You're debugging installation issues
- You only need specific packages
- The `dot` script doesn't work for your setup

**When to use the script:**

- You want automated setup with backups
- You need template processing and secret merging
- You want health checks and validation
- You prefer a guided installation experience

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
./dot update       # Update configs, Oh My Zsh, and reinstall
```

The `update` command automatically:

1. Updates global gitignore patterns
2. Updates Oh My Zsh to latest version
3. Pulls submodule updates
4. Reinstalls all packages

Like `install`, the `update` command supports verbosity flags:

```bash
./dot update       # Clean summary
./dot update -v    # Show packages and progress
./dot update -vv   # Show all file operations
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

## Contributing

Interested in contributing? See [DEVELOPMENT.md](DEVELOPMENT.md) for comprehensive developer documentation:

- Development environment setup
- Git workflow and branch strategy
- Testing and CI/CD
- Code standards and Bash 3.2 compatibility
- Linting tools and commands
- Debugging tips
- Architecture and design principles

For AI agents, see [AGENTS.md](AGENTS.md) for detailed guidelines.
