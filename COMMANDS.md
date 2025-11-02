# Command Reference

Complete reference for all `./dot` commands.

## Quick Reference

| Command | Description | Example |
|---------|-------------|---------|
| `install` | Install all dotfiles | `./dot install -v` |
| `update` | Update and reinstall | `./dot update` |
| `status` | Show installation status | `./dot status` |
| `health` | Run diagnostics | `./dot health -v` |
| `packages` | List all packages | `./dot packages` |
| `enable` | Enable a package | `./dot enable rust` |
| `disable` | Disable a package | `./dot disable fish` |
| `diff` | Preview changes | `./dot diff` |
| `backup` | Create backup | `./dot backup` |
| `backups` | List backups | `./dot backups` |
| `restore` | Restore from backup | `./dot restore 1730000000` |
| `clean` | Clean old backups | `./dot clean` |
| `security` | Security audit | `./dot security` |
| `uninstall` | Remove all symlinks | `./dot uninstall` |
| `sync` | Sync package to system | `./dot sync cursor` |
| `pull` | Pull package from system | `./dot pull cursor` |

## Installation Commands

### `./dot install [OPTIONS]`

Install all dotfiles packages using GNU Stow.

**What it does:**

1. Validates dependencies (stow, git, bash 3.2+)
2. Backs up existing files
3. Creates symlinks from packages to home directory
4. Validates configuration syntax

**Options:**

- `-v, --verbose` - Show package names and progress (level 1)
- `-vv` - Show every file operation (level 2)
- `-h, --help` - Show help message

**Examples:**

```bash
# Basic installation (summary only)
./dot install

# Show which packages are being installed
./dot install -v

# Show every file being symlinked
./dot install -vv
```

**What gets installed:**

All packages with valid `manifest.toml` files in `packages/` directory:

- system - Global ignore patterns
- git - Git configuration and aliases
- zsh - Zsh shell configuration
- bash - Bash shell configuration
- fish - Fish shell configuration
- tmux - Terminal multiplexer
- gh - GitHub CLI configuration
- gnuplot - Plotting configuration
- wezterm - Terminal emulator
- bat - Syntax highlighter
- rust - Rust toolchain configuration
- cursor - IDE configuration (copy-sync method)

**Recovery:**

If installation fails, automatic rollback removes any changes made.

### `./dot update [OPTIONS]`

Update configurations and reinstall all packages.

**What it does:**

1. Updates global gitignore patterns
2. Runs package-specific update commands (if defined in manifests)
3. Reinstalls all packages

**Options:**

Same as `install`: `-v`, `-vv`, `-h`

**Examples:**

```bash
# Update with summary
./dot update

# Update with progress details
./dot update -v
```

**When to use:**

- After pulling latest changes from repository
- Periodically to refresh global patterns
- After modifying package configurations

### `./dot uninstall`

Remove all dotfiles symlinks.

**What it does:**

Removes symlinks created by stow for all packages, leaving your original files intact.

**Example:**

```bash
./dot uninstall
```

**Safety:**

Backups are NOT automatically created. Run `./dot backup` first if you want to preserve current state.

## Package Management

### `./dot packages`

List all available packages with their status.

**Output format:**

```text
Package         Status       Description
────────────────────────────────────────
✓ git           (enabled)    Git configuration
✗ rust          (disabled)   Rust toolchain
```

**Example:**

```bash
./dot packages
```

### `./dot enable PACKAGE`

Enable (install) a specific package.

**Arguments:**

- `PACKAGE` - Name of package to enable

**Examples:**

```bash
# Enable rust package
./dot enable rust

# Enable multiple packages (one at a time)
./dot enable rust
./dot enable bat
```

**What it does:**

1. Validates package exists and has valid manifest
2. Backs up any conflicting files
3. Creates symlinks for package files
4. Runs package validation (if defined)

### `./dot disable PACKAGE`

Disable (uninstall) a specific package.

**Arguments:**

- `PACKAGE` - Name of package to disable

**Examples:**

```bash
# Disable fish shell package
./dot disable fish
```

**What it does:**

Removes symlinks for the specified package only, leaving other packages intact.

### `./dot sync PACKAGE`

Sync package files from dotfiles to system (for copy-sync packages).

**Arguments:**

- `PACKAGE` - Name of copy-sync package (currently: cursor)

**Examples:**

```bash
# Sync cursor settings to Cursor IDE
./dot sync cursor
```

**When to use:**

- After pulling latest dotfiles changes
- After modifying package files in repository
- Setting up on a new machine

**Copy-sync packages:**

Only certain packages use copy-sync instead of symlinks:

- `cursor` - Cursor IDE doesn't handle symlinked configs well

### `./dot pull PACKAGE`

Pull package files from system to dotfiles (for copy-sync packages).

**Arguments:**

- `PACKAGE` - Name of copy-sync package

**Examples:**

```bash
# Pull cursor settings from Cursor IDE back to dotfiles
./dot pull cursor

# Then commit the changes
git add packages/cursor
git commit -m "update cursor settings"
```

**When to use:**

After making changes in the application (e.g., Cursor IDE) that you want to save to version control.

## Status and Diagnostics

### `./dot status`

Show installation status and recent backups.

**What it shows:**

- Symlink status for all packages
- Recent backups with size and age
- Orphaned symlinks (if any)
- Missing dependencies

**Example:**

```bash
./dot status
```

**Output includes:**

- ✓ Installed packages (green)
- ✗ Not installed packages (red)
- Backup count and total size
- Disk space usage

### `./dot health [OPTIONS]`

Run comprehensive diagnostics.

**Options:**

- `-v, --verbose` - Detailed output instead of table format

**Examples:**

```bash
# Table format (quick overview)
./dot health

# Detailed format (full diagnostics)
./dot health -v
```

**What it checks:**

1. **Symlink Integrity** - All symlinks point to correct files
2. **Configuration Syntax** - Git, tmux, zsh, bash configs are valid
3. **Git Repository Status** - Uncommitted changes, sync status
4. **File Permissions** - Secret files have secure permissions (600)
5. **Shell Integration** - Configs are active, PATH is correct
6. **Stow Conflicts** - No unmanaged files blocking installation
7. **Orphaned Symlinks** - Broken symlinks in home directory
8. **Dependencies** - All required tools installed
9. **Backup Health** - Backup count and cleanup suggestions

**Exit codes:**

- 0 - All checks passed
- 1 - One or more checks failed

### `./dot diff`

Preview changes before applying.

**What it shows:**

Shows what would change if you ran `./dot install` or `./dot update` without actually making changes.

**Example:**

```bash
./dot diff
```

**Output:**

- Files that would be symlinked
- Existing files that would be backed up
- Potential conflicts

**When to use:**

- Before running `install` or `update`
- After pulling repository changes
- To verify what installation would do

### `./dot security`

Run security audit on dotfiles.

**What it checks:**

- File permissions on sensitive files
- Secret file exposure risks
- Git repository security settings
- Suspicious patterns in configurations

**Example:**

```bash
./dot security
```

**Recommendations:**

- Run after initial installation
- Run periodically (monthly)
- Run before committing changes with sensitive data

## Backup and Restore

### `./dot backup`

Create backup of existing files.

**What it backs up:**

All files that would be replaced by symlinks during installation.

**Backup location:**

`backups/dotfiles-backup-TIMESTAMP/`

**Example:**

```bash
./dot backup
```

**When to use:**

- Before making significant changes
- Before running `./dot install` on existing configs
- Manually preserving current state

**Auto-backups:**

The `install` and `update` commands automatically create backups before making changes.

### `./dot backups`

List all available backups with details.

**Output includes:**

- Backup timestamp and age
- Number of files in backup
- Backup size
- Backup directory path

**Example:**

```bash
./dot backups
```

**Sample output:**

```text
Available backups:
  1730000000  2024-10-27 10:00:00  (5 days ago)   45 files  2.3 MB
  1729800000  2024-10-24 15:30:00  (8 days ago)   43 files  2.1 MB
```

### `./dot restore [BACKUP_ID]`

Restore from a specific backup.

**Arguments:**

- `BACKUP_ID` - Timestamp of backup to restore (from `./dot backups`)
- If omitted, shows available backups and prompts for selection

**Examples:**

```bash
# Interactive mode (shows list and prompts)
./dot restore

# Direct restore from specific backup
./dot restore 1730000000
```

**What it does:**

1. Creates safety backup of current state
2. Removes current symlinks
3. Restores files from specified backup
4. Confirms restoration success

**Safety:**

Always creates a pre-restore backup at `backups/dotfiles-pre-restore-TIMESTAMP/` before modifying files.

### `./dot clean`

Clean up old backup directories.

**What it does:**

Removes backup directories beyond the retention limit (default: 10 most recent backups).

**Example:**

```bash
./dot clean
```

**Configuration:**

Set retention limit via environment variable:

```bash
DOTFILES_MAX_BACKUPS_TO_KEEP=20 ./dot clean
```

**Safety:**

- Always keeps the most recent N backups
- Prompts for confirmation before deletion
- Shows space that would be freed

## Options and Flags

### Verbosity Levels

Control output detail:

- `(none)` - Summary only (task completion + errors/warnings)
- `-v` - Add package names and progress details
- `-vv` - Show every file operation

**Stacking:**

```bash
./dot install -v -v              # Same as -vv
./dot install --verbose --verbose # Same as -vv
```

**Supported commands:**

`install`, `update` support `-v` and `-vv`
`health` has binary verbosity (table vs detailed)

### Help

Get usage information:

```bash
./dot --help
./dot -h
```

## Shell Completion

Generate shell completion scripts:

```bash
# Bash
./dot --completion bash

# Zsh  
./dot --completion zsh

# Fish
./dot --completion fish
```

**Installation:**

```bash
# Bash
source <(./dot --completion bash)

# Zsh
source <(./dot --completion zsh)

# Fish
./dot --completion fish | source
```

Add to your shell config to load on startup.

## Exit Codes

- `0` - Success
- `1` - Failure (error details in output)

## Environment Variables

See [README.md § Configuration](README.md#configuration) for full list of configuration options:

- `DOTFILES_MAX_BACKUPS_TO_KEEP` - Backup retention (default: 10)
- `DOTFILES_GIT_TIMEOUT` - Git operation timeout (default: 60s)
- `DOTFILES_SECRET_FILE_MODE` - Secret file permissions (default: 600)
- And more...

## Common Workflows

### Initial Setup

```bash
git clone git@github.com:hamishmorgan/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./dot install -v
```

### Daily Usage

```bash
# Check status
./dot status

# Run diagnostics  
./dot health

# Update configurations
git pull
./dot update -v
```

### Adding a Package

```bash
# Enable new package
./dot enable rust

# Disable unwanted package
./dot disable fish
```

### Troubleshooting

```bash
# Check health (detailed)
./dot health -v

# Preview what would change
./dot diff

# Restore from backup
./dot backups
./dot restore TIMESTAMP
```

### Before Making Changes

```bash
# Create manual backup
./dot backup

# Check current state
./dot status

# Run security audit
./dot security
```

## Deprecated Commands

### `./dot validate` (deprecated)

**Status:** Deprecated - Use `./dot health` instead

The `validate` command has been renamed to `health` for clarity. The old command still works but will
show a deprecation warning:

```bash
# Old (deprecated)
./dot validate

# New (recommended)
./dot health
```

Both commands provide the same functionality - running comprehensive diagnostics on your dotfiles installation.

## See Also

- [README.md](README.md) - User guide and installation instructions
- [DEVELOPMENT.md](DEVELOPMENT.md) - Developer documentation
- [CONTRIBUTING.md](CONTRIBUTING.md) - Contribution guidelines
- [AGENTS.md](AGENTS.md) - AI agent instructions
