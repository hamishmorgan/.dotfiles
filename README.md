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
├── packages/      # All stowable configuration packages
│   ├── git/           # Git configuration and aliases
│   │   ├── .gitconfig              # Git config (tracked)
│   │   └── .gitconfig.local.example  # Example for ~/.gitconfig.local
│   ├── zsh/           # Zsh configuration with Oh My Zsh
│   │   ├── .zshrc
│   │   ├── .zprofile
│   │   ├── .zshrc.osx
│   │   ├── .zshrc.linux
│   │   ├── .zshrc.local.example    # Example for ~/.zshrc.local
│   │   └── .oh-my-zsh/  # Oh My Zsh submodule
│   ├── tmux/          # Tmux configuration
│   ├── gh/            # GitHub CLI configuration
│   │   └── .config/gh/
│   │       ├── config.yml          # GH CLI config (tracked)
│   │       └── hosts.yml           # GH hosts config (tracked)
│   ├── gnuplot/       # GNU Plot configuration
│   ├── bash/          # Bash configuration
│   │   ├── .bashrc
│   │   ├── .bash_profile
│   │   └── .bashrc.local.example   # Example for ~/.bashrc.local
│   ├── fish/          # Fish shell configuration
│   │   └── .config/fish/
│   │       ├── config.fish
│   │       ├── config.linux.fish
│   │       ├── config.osx.fish
│   │       └── functions/
│   │           ├── d.fish           # Dotfiles wrapper function
│   │           └── fish_prompt.fish # Custom prompt
│   └── system/        # System-wide files
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

### Security

### Output

- `DOTFILES_OUTPUT_PREFIX` - Output indentation character (default: │)

### Backup Paths

- `DOTFILES_BACKUP_DIR_PREFIX` - Backup directory prefix (default: backups/dotfiles-backup)
- `DOTFILES_RESTORE_SAFETY_PREFIX` - Restore safety prefix (default: backups/dotfiles-pre-restore)

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

# Plain ASCII output for CI/logs
DOTFILES_OUTPUT_PREFIX="| " ./dot install

# Custom backup location
DOTFILES_BACKUP_DIR_PREFIX=.archive/dotfiles ./dot backup
```

## Optional Enhancements

### Git Delta - Enhanced Diff Viewer

[Git-delta](https://github.com/dandavison/delta) provides enhanced diffs with:

- Syntax-highlighted diffs
- Side-by-side view
- Line numbers
- Better visualization of changes

**Installation:**

```bash
# macOS
brew install git-delta

# Ubuntu/Debian
wget https://github.com/dandavison/delta/releases/download/0.18.2/git-delta_0.18.2_amd64.deb
sudo dpkg -i git-delta_0.18.2_amd64.deb

# Cargo (all platforms)
cargo install git-delta
```

**Activation:**

After installing delta, enable it by adding to `~/.gitconfig.local`:

```gitconfig
[include]
    path = ~/.gitconfig.delta
```

The `.gitconfig.delta` file is automatically symlinked during `./dot install` and contains
pre-configured delta settings (Dracula theme, side-by-side view, line numbers).

### Set zsh as default shell

```bash
chsh -s $(which zsh)
```

Log out and back in for the change to take effect.

### Modern CLI Tools

The dotfiles include optional integrations for modern CLI tools. These tools are detected automatically and
aliases are configured if installed.

#### eza (modern ls replacement)

[eza](https://github.com/eza-community/eza) is a modern replacement for `ls` with better defaults, icons,
git integration, and tree views.

**Installation:**

```bash
# macOS
brew install eza

# Ubuntu/Debian (via cargo)
cargo install eza

# Or download binary from GitHub releases
```

**Aliases (auto-configured when eza is installed):**

- `ls` - Basic listing with icons and grouped directories
- `ll` - Long format with headers, icons, and git status
- `la` - Long format with all files (including hidden)
- `lt` - Tree view (2 levels)
- `lta` - Tree view with hidden files
- `lg` - Git-enhanced listing (shows git status)
- `lm` - Time-sorted (most recently modified first)
- `lz` - Size-sorted (largest first)

**Testing:**

```bash
# Verify eza is installed
command -v eza

# Test aliases
ll
lt
lg
```

The aliases are integrated into `.bashrc`, `.zshrc`, and `config.fish`. If eza is not installed,
the shell configs fall back to standard `ls` aliases.

### Manual Installation

The `dot` script is optional. These dotfiles are standard GNU Stow packages and can be managed manually.

#### 1. Clone Repository

```bash
git clone git@github.com:hamishmorgan/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive
```

#### 2. Create Machine-Specific Configuration

Create `.local` files for your machine-specific settings (git-ignored):

**Git configuration (required):**

```bash
cp packages/git/.gitconfig.local.example ~/.gitconfig.local
# Edit with your information:
# - name, email, username
# - Signing configuration (1Password, Yubikey, or disable)
nano ~/.gitconfig.local
chmod 600 ~/.gitconfig.local
```

**Shell configuration (optional):**

```bash
# Bash
cp packages/bash/.bashrc.local.example ~/.bashrc.local
nano ~/.bashrc.local

# Zsh
cp packages/zsh/.zshrc.local.example ~/.zshrc.local
nano ~/.zshrc.local

# Fish
nano ~/.config/fish/config_private.fish
```

#### 3. Install Packages with Stow

```bash
# Install system package first (provides .stow-global-ignore)
stow --verbose --restow --dir=packages --target=$HOME system

# Install other packages
stow --verbose --restow --dir=packages --target=$HOME git zsh tmux gh gnuplot bash fish

# Or install selectively
stow --verbose --restow --dir=packages --target=$HOME git zsh
```

**What Stow does:**

- Creates symlinks from `~/.dotfiles/packages/PACKAGE/FILE` to `~/FILE`
- Example: `~/.dotfiles/packages/git/.gitconfig` → `~/.gitconfig`
- Handles nested directory structures automatically

#### 5. Verify Installation

```bash
# Check symlinks were created
ls -la ~ | grep "^l"

# Should show:
# lrwxr-xr-x .gitconfig -> .dotfiles/packages/git/.gitconfig
# lrwxr-xr-x .zshrc -> .dotfiles/packages/zsh/.zshrc

# Test configurations (from your ~/.gitconfig.local)
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
stow --verbose --restow --dir=packages --target=$HOME git zsh tmux gh gnuplot bash fish
```

#### Manual Uninstall

```bash
cd ~/.dotfiles

# Remove all symlinks
stow --verbose --delete --dir=packages --target=$HOME system git zsh tmux gh gnuplot bash fish

# Or remove specific packages
stow --verbose --delete --dir=packages --target=$HOME git
```

**When to use manual installation:**

- You want full control over each step
- You're learning how Stow works
- You're debugging installation issues
- You only need specific packages
- The `dot` script doesn't work for your setup

**When to use the script:**

- You want automated setup with backups
- You want health checks and validation
- You want automatic .local file permission setting
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

The health check performs 10 categories of checks:

1. **Symlink Integrity**: Verifies all configuration symlinks point to correct files
2. **Configuration Syntax**: Validates git, tmux, zsh, and bash configuration syntax
3. **Submodule Health**: Checks Oh My Zsh submodule status and initialization
4. **Git Repository Status**: Reports uncommitted changes, branch status, and sync with origin
5. **File Permissions**: Ensures .local files have secure permissions (chmod 600)
6. **Shell Integration**: Verifies shell configs are active and PATH is properly configured
7. **Stow Conflicts**: Detects unmanaged files that would conflict with stow
8. **Orphaned Symlinks**: Finds broken symlinks in home and .config directories
9. **Dependencies**: Checks all required tools are installed
10. **Backup Health**: Reports backup directory status and suggests cleanup if needed

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

## Machine-Specific Configuration

This dotfiles setup supports machine-specific configurations through `.local` files.
These files are git-ignored and allow you to customize settings per machine without
affecting the shared configuration.

### Setting Up Machine-Specific Configuration

**Bash:**

```bash
cp ~/.dotfiles/packages/bash/.bashrc.local.example ~/.bashrc.local
nano ~/.bashrc.local
```

**Zsh:**

```bash
cp ~/.dotfiles/packages/zsh/.zshrc.local.example ~/.zshrc.local
nano ~/.zshrc.local
```

**Git:**

```bash
cp ~/.dotfiles/packages/git/.gitconfig.local.example ~/.gitconfig.local
nano ~/.gitconfig.local
```

**Fish:**

```bash
# Fish uses config_private.fish instead of config.local.fish
nano ~/.config/fish/config_private.fish
```

### Use Cases for .local Files

- Machine-specific aliases and functions
- Private API keys or environment variables
- Git signing configuration (different per machine)
- Tool-specific settings that vary by environment
- Work vs. personal customizations

### Handling Auto-Appending Tools

Some development tools (like Shopify's `dev` and `tec agent`) automatically append
initialization code to shell configuration files. This dotfiles setup handles this by:

1. **Pre-including integrations**: Common tool integrations are pre-added with conditional
   checks, so they're safe on all machines
2. **Graceful duplication**: When tools re-append, they create duplicates that can be
   safely ignored or cleaned up
3. **Git workflow**: Use `git add -p` to interactively stage changes, skipping duplicates

**Managing git noise from auto-appends:**

```bash
# Option A: Interactive staging (skip duplicate lines)
git add -p packages/bash/.bashrc

# Option B: Reset shell configs before committing other changes
git checkout -- packages/bash/.bashrc packages/zsh/.zshrc
git add <other-files>
git commit -m "Your changes"

# Option C: Commit everything, clean up duplicates later
git commit -am "WIP: changes"
```

## Secure File Permissions

Machine-specific `.local` files contain sensitive information and are automatically
secured with `chmod 600` (owner read/write only) during installation.

**Files secured:**

- `~/.gitconfig.local` - User identity and git signing keys
- `~/.bashrc.local` - May contain API keys or tokens
- `~/.zshrc.local` - May contain private environment variables
- `~/.config/fish/config_private.fish` - Private fish configuration

The installation script automatically sets secure permissions on these files if they exist.

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

## Development

Development workflow commands are available in the `dev/` directory.

### Quick Start

```bash
# Setup development environment
./dev/setup

# Fast iteration
./dev/lint-shell        # Check shell scripts only
./dev/smoke             # Quick validation

# Before commit
./dev/lint && ./dev/test

# Before push
./dev/check             # Run everything (lint + test + ci)
```

### Available Commands

**Atomic Commands** (single responsibility):

```bash
./dev/lint-markdown     # Lint Markdown files (~5s)
./dev/lint-shell        # Lint shell scripts (~5s)
./dev/smoke             # Fast structural validation (~30s)
./dev/bats              # BATS test suites (~30s)
./dev/ci                # Local CI in containers (~2-3m)
./dev/setup             # Setup development environment
./dev/clean             # Clean temporary files
```

**Composite Commands** (orchestration):

```bash
./dev/lint              # All linting (~10s)
./dev/test              # All tests (~1m)
./dev/check             # Complete validation (~3-4m)
./dev/help              # Show all commands
```

### VSCode Integration

Run tasks via Command Palette (`Ctrl+Shift+P` → `Tasks: Run Task`):

- `Dev: Check (All Validation)` - Complete validation
- `Dev: Lint (All)` - All linters
- `Dev: Test (Smoke + BATS)` - All tests
- Individual atomic commands also available

## Disk Cleanup Utility

A comprehensive disk space cleanup utility for developers at `bin/disk-cleanup`.

### Quick Usage

```bash
# Interactive mode (recommends, asks for confirmation)
./bin/disk-cleanup

# Non-interactive, safe operations only
./bin/disk-cleanup --yes

# Preview what would be cleaned
./bin/disk-cleanup --dry-run

# Aggressive cleanup (Docker images, etc.)
./bin/disk-cleanup --yes --aggressive
```

### Features

- **25+ Developer Tools**: Cleans caches for Homebrew, npm, yarn, Docker, Git, RubyGems, pip, Go, and more
- **Per-Tool Space Reporting**: Shows exactly how much each tool cleaned
- **Multiple Aggression Levels**: Safe defaults with optional aggressive modes
- **Git Repository Auto-Discovery**: Finds and cleans repos in common locations
- **System Cache Cleaning**: macOS thumbnails, font caches (optional, requires sudo)
- **Comprehensive Logging**: Detailed logs in `~/.cache/dev-cleanup/`
- **Cross-Platform**: Works on macOS and Linux
- **Bash 3.2 Compatible**: No external dependencies

### Categories

The utility cleans seven categories of developer artifacts:

1. **Package Managers**: Homebrew, apt, yum/dnf
2. **Language Tools**: npm, yarn, pnpm, gem, pip, go, composer
3. **Build Tools**: bundler, ccache
4. **Git Repositories**: Auto-discovered in `~/Projects`, `~/src`, `~/world`, etc.
5. **Docker/Podman**: Containers, images, volumes (configurable)
6. **System Caches**: macOS thumbnails and fonts (optional)
7. **Xcode** (macOS): Simulators, derived data, archives

### Options

```bash
# Verbosity
-q, --quiet              # Minimal output
-v, --verbose            # Detailed output

# Modes
-n, --dry-run            # Preview without executing
-y, --yes                # Non-interactive mode

# Aggression
--aggressive             # More thorough (all unused Docker images)
--very-aggressive        # Most thorough (includes volumes - WARNING)

# Git
--prune-git              # Prune git repos (gc --prune=now)
--aggressive-git         # Aggressive git gc (slow on large repos)

# Scope
--system-caches          # Include system caches (requires sudo)
--detailed-space         # Measure per-tool space savings (slower)
--only=CATEGORIES        # Only run specific categories
--exclude=CATEGORIES     # Exclude specific categories

# Examples
./bin/disk-cleanup --only=languages,docker
./bin/disk-cleanup --exclude=git,system
```

### Environment Variables

All configuration options can be set via environment variables:

```bash
CLEANUP_GIT_GC_TIMEOUT=300          # Git gc timeout (seconds)
CLEANUP_DOCKER_TIMEOUT=300          # Docker cleanup timeout
CLEANUP_BREW_TIMEOUT=600            # Homebrew cleanup timeout
CLEANUP_GIT_MAX_DEPTH=3             # Max depth for git repo search
CLEANUP_LOG_DIR="$HOME/.cache/dev-cleanup"
CLEANUP_KEEP_LOGS=10                # Number of log files to keep
```

### Safety

- **Safe defaults**: Only runs non-destructive cleanups without confirmation
- **Confirmation prompts**: Asks before destructive operations (Docker prune)
- **Non-interactive safety**: `--yes` mode skips destructive operations unless combined with `--aggressive`
- **Dry-run mode**: Preview exact commands before executing
- **Comprehensive logging**: All operations logged for troubleshooting
- **Graceful failures**: Continues cleaning other tools if one fails

### Example Output

```text
Disk Space Cleanup Utility v1.0.0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Initial disk usage: 485.2 GB

Language Tools
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[1/24] ✓ npm cache                           834 MB cleaned
[2/24] ✓ yarn cache                          245 MB cleaned
[3/24] ✓ RubyGems                            89 MB cleaned

Git Repositories
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[4/24] ✓ ~/.dotfiles                         4 MB cleaned
[5/24] ✓ ~/Projects/myapp                    89 MB cleaned

Total space reclaimed: 10.8 GB
Final disk usage: 474.4 GB

Detailed log: ~/.cache/dev-cleanup/cleanup-20250124-143022.log
```

## Contributing

See [DEVELOPMENT.md](DEVELOPMENT.md) for comprehensive developer documentation:

- Git workflow and branch strategy
- Testing framework and CI/CD
- Code standards and Bash 3.2 compatibility
- Architecture and design principles

For AI agents, see [AGENTS.md](AGENTS.md) for detailed guidelines.
