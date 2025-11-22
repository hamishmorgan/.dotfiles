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

**Options:** `-v` (verbose), `-vv` (very verbose), `-h` (help)

```bash
./dot install       # Summary only
./dot install -v    # Show packages
./dot install -vv   # Show every file
```

**Process:** Validates dependencies, backs up existing files, creates symlinks, validates configuration.
Automatic rollback on failure.

### `./dot update [OPTIONS]`

Update configurations and reinstall all packages.

```bash
./dot update       # Summary only
./dot update -v    # Show progress
```

**Process:** Updates global gitignore patterns, runs package-specific updates, reinstalls all packages.

### `./dot uninstall`

Remove all dotfiles symlinks.

```bash
./dot uninstall
```

**Note:** Does not create automatic backup. Run `./dot backup` first to preserve current state.

## Package Management

### `./dot packages`

List all packages with status (enabled/disabled).

```bash
./dot packages
```

### `./dot enable PACKAGE`

Enable (install) a specific package.

```bash
./dot enable rust
./dot enable bat
```

### `./dot disable PACKAGE`

Disable (uninstall) a specific package.

```bash
./dot disable fish
```

### `./dot sync PACKAGE`

Sync package files from dotfiles to system (for copy-sync packages like cursor).

```bash
./dot sync cursor
```

**Use when:** After pulling dotfiles changes or modifying package files in repository.

### `./dot pull PACKAGE`

Pull package files from system back to dotfiles (for copy-sync packages).

```bash
./dot pull cursor
git add packages/cursor
git commit -m "update cursor settings"
```

## Status and Diagnostics

### `./dot status`

Show installation status, backups, and dependencies.

```bash
./dot status
```

### `./dot health [OPTIONS]`

Run comprehensive diagnostics.

```bash
./dot health       # Table format
./dot health -v    # Detailed output
```

**Checks:** Symlink integrity, configuration syntax, git status, file permissions, shell integration,
stow conflicts, orphaned symlinks, dependencies, backup health.

### `./dot diff`

Preview what would change without making changes.

```bash
./dot diff
```

### `./dot security`

Run security audit on dotfiles (file permissions, secret exposure, git security).

```bash
./dot security
```

## Backup and Restore

### `./dot backup`

Create manual backup of existing files.

```bash
./dot backup
```

**Location:** `backups/dotfiles-backup-TIMESTAMP/`

**Note:** `install` and `update` create automatic backups.

### `./dot backups`

List all backups with timestamp, age, file count, and size.

```bash
./dot backups
```

### `./dot restore [BACKUP_ID]`

Restore from backup. Interactive if no ID provided.

```bash
./dot restore              # Interactive selection
./dot restore 1730000000   # Direct restore
```

**Safety:** Creates pre-restore backup at `backups/dotfiles-pre-restore-TIMESTAMP/`.

### `./dot clean`

Remove old backups beyond retention limit (default: 10).

```bash
./dot clean
DOTFILES_MAX_BACKUPS_TO_KEEP=20 ./dot clean
```

## Options

**Verbosity:** `-v` (verbose), `-vv` (very verbose) - Supported by `install` and `update`

**Help:** `-h, --help`

**Shell Completion:** `./dot completion <bash|zsh|fish>` - Add to shell config: `source <(./dot completion bash)`

**Environment Variables:** See [README.md § Configuration](README.md#configuration)

## Common Workflows

```bash
# Initial setup
git clone git@github.com:hamishmorgan/.dotfiles.git ~/.dotfiles && cd ~/.dotfiles && ./dot install -v

# Daily usage
./dot status && ./dot health && git pull && ./dot update -v

# Package management
./dot packages && ./dot enable rust && ./dot disable fish

# Troubleshooting
./dot health -v && ./dot diff && ./dot backups && ./dot restore TIMESTAMP

# Before changes
./dot backup && ./dot status && ./dot security
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
