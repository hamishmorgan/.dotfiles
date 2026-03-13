# Agent Instructions

## Project Context

GNU Stow-managed dotfiles. Packages under `packages/`:
bash, bat, claude, fish, gh, git, gnuplot, ripgrep, rust, system, tmux, wezterm, zsh.

**Repository layout:**

- `packages/`: Stowable configuration packages (each has `manifest.toml`)
- `dev/`: Development tools (linting, testing, CI)
- `tests/`: Test infrastructure (BATS, smoke tests, CI)
- `dot`: Main user-facing script
- `tmp/`: Temporary files (git-ignored)

**Documentation:** README.md (user), DEVELOPMENT.md (developer), AGENTS.md (agent), tests/README.md (testing).

### Machine-Specific Configuration

Single-branch approach with `.local` file overrides (git-ignored):

```text
~/.bashrc               # Symlinked from repo (base config)
~/.bashrc.local         # Git-ignored, machine-specific
~/.config/bash/conf.d/  # Machine-specific .bash files auto-loaded
~/.gitconfig            # Generated from template + secret
~/.gitconfig.local      # Git-ignored, machine-specific
```

Auto-appending tools (Shopify `dev`, `tec agent`) forcibly append to shell configs daily.
No prevention mechanism exists. Strategy: pre-include integrations + accept git noise + `git add -p` to skip duplicates.

## Dependencies

**Required:** stow 2.x+, git 2.x+, bash 3.2+ (macOS default).

**Optional:** gh, jq, docker/podman, markdownlint-cli, shellcheck, python3 (TOML/YAML validation).

## Code Standards

- Use long-form arguments for stow (`--verbose` not `-v`)
- Use POSIX short-form for coreutils (`-p`, `-r` not `--parents`, `--recursive`) — BSD/macOS lacks GNU long-form
- Use explicit error handling instead of `set -e`
- Enable `shopt -s nullglob extglob`
- Follow `.editorconfig`: LF endings, final newline, 2-space indent for shell, trim trailing whitespace
- **Package independence**: `dot` script MUST NOT contain package-specific logic. Extend `manifest.toml` format instead.

### Environment Variables

**Naming:** External `DOTFILES_<NAME>` maps to internal readonly `<NAME>`.

**Current variables:**

| Variable | Default | Purpose |
|---|---|---|
| `DOTFILES_MAX_BACKUPS_TO_DISPLAY` | 5 | Status output |
| `DOTFILES_MAX_BACKUPS_TO_KEEP` | 10 | Retention policy |
| `DOTFILES_RESTORE_DISPLAY_LIMIT` | 20 | Restore preview |
| `DOTFILES_GIT_TIMEOUT` | 60 | Git operations |
| `DOTFILES_CURL_TIMEOUT` | 30 | Curl downloads |
| `DOTFILES_SECRET_FILE_MODE` | 600 | Secret file permissions |
| `DOTFILES_OUTPUT_PREFIX` | `│` | Indentation character |
| `DOTFILES_BACKUP_DIR_PREFIX` | backups/dotfiles-backup | Backup directory |
| `DOTFILES_RESTORE_SAFETY_PREFIX` | backups/dotfiles-pre-restore | Restore safety |

Pattern: `readonly INTERNAL_NAME="${DOTFILES_INTERNAL_NAME:-default}"`.

### Argument Parsing

Commands with arguments use the `COMMAND_ARGS` array pattern.
`parse_arguments()` consumes all args, so `$@` is empty in `main()`.
Collect remaining args into `COMMAND_ARGS=()` and pass via
`"${COMMAND_ARGS[@]}"`.

### Bash 3.2 Compatibility

Required for macOS. Prohibited features:

- `declare -A` (associative arrays) — use `case` functions
- `mapfile` — use `while IFS= read -r` loops
- `&>>` — use `>> file 2>&1`

Test: `./tests/run-local-ci.sh bash32`

## Git Commit Attribution

AI agent commits must use `--author` flag:

```bash
git commit --author="Claude <claude@noreply.local>" -m "message"
git commit --author="Cursor <cursor@noreply.local>" -m "message"
```

## File Organization

- **Path variables**: `DOTFILES_DIR` (repo root),
  `PACKAGES_DIR` (`$DOTFILES_DIR/packages`).
  Always use `$PACKAGES_DIR` for package paths.
- `.gitignore` is project-specific, not stow-managed.

### Package Manifests

**Mandatory.** All packages require `manifest.toml`. No fallback.

```toml
# Required
files = [".config/file1", ".config/file2"]

# Optional (with defaults)
name = "Package Name"           # default: directory name
description = "Description"     # default: empty
method = "stow"                 # or "copy-sync"
target = "~"

# Platform overrides
target.macos = "~/Library/Application Support/App"
target.linux = "~/.config/app"

# Validation and update hooks
[validation]
".gitconfig" = { command = "git", args = ["config", "--list"] }

[update]
command = "dev/update-script"
args = ["file"]
```

**Parser limitations** (custom bash, 3.2-compatible):
no escaped quotes in values, no multi-line strings,
no TOML tables (only inline), no arrays of tables, no dotted table names.

### File Listing

**Always list individual files** in manifests, not directories.
Listing a directory causes `backup_existing()` to `rm -rf` the entire
directory, destroying user data (e.g., `.cargo/bin/`, `.cargo/credentials.toml`).

Directories acceptable only when dotfiles owns ALL content (e.g., submodules).

### Stow and Config Patterns

- `.stow-global-ignore` in system package (symlinked to `~/`)
- `.stow-local-ignore` per package for templates/secrets/examples
- `.local` files are git-ignored and NOT stowed
- Optional enhancement configs (e.g., `.gitconfig.delta`): stowed, user activates via `.local` include
- Platform configs: `.config/bash/conf.d/darwin.bash`, `.zshrc.osx`, `.zshrc.linux`

## Logging System

Symbol-based output: `●` info, `✓` success, `⚠` warning, `✗` error.
Subcommand output prefixed with `│`, colorized by content pattern.

Variables: `SYMBOL_SUCCESS="✓"`, `SYMBOL_ERROR="✗"`, `SYMBOL_WARNING="⚠"`, `SYMBOL_INFO="∙"`.

## Verbosity System

3 levels for `install`/`update`: 0 (summary), 1 (`-v`, package names), 2 (`-vv`, all file ops).

Helpers: `run_with_verbosity()`, `run_step()`, `show_installation_summary()`.
`health` command: binary verbosity (table vs detailed with `-v`).

## Helper Functions

Prefer existing helpers over duplicating logic:
`get_backup_stats()`, `count_orphaned_symlinks()`, `show_installation_summary()`,
`show_tip()`/`show_tips()`, `run_health_check()`, `run_with_verbosity()`, `run_step()`.

## Code Quality

- Markdown: must pass markdownlint (config: `.markdownlint.yml`)
- Shell: must pass shellcheck (config: `.shellcheckrc`)
- Run `make check` before committing

## Quick Reference

| Task | Command |
|---|---|
| Install | `./dot install` (`-v`, `-vv`) |
| Update | `./dot update` (`-v`, `-vv`) |
| Health check | `./dot health` (`-v`) |
| Status | `./dot status` |
| Fast checks | `make check` |
| All tests | `make test` |
| Shell lint | `make check-shell` |
| Markdown lint | `make check-markdown` |
| Smoke tests | `make test-smoke` |
| BATS tests | `make test-bats` |
| Local CI | `PLATFORM=alpine make ci` |
| Setup dev | `make deps` |
| All commands | `make help` |

## Testing

Categories: regression (per-bug, before fix), unit, integration, contract (output format), smoke (structural).

See `tests/README.md` for framework details.
