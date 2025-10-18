# Agent Instructions

Instructions for AI agents working with this dotfiles repository.

## Project Context

This repository contains dotfiles managed with GNU Stow. Files are organized into packages:

- **system**: System-wide configuration files (`.stow-global-ignore`)
- **git**: Git configuration and global ignore patterns
- **zsh**: Zsh shell configuration (includes Oh My Zsh as submodule)
- **tmux**: Terminal multiplexer configuration
- **gh**: GitHub CLI configuration
- **gnuplot**: GNU Plot configuration
- **bash**: Bash shell configuration

Template-based secrets management separates public templates from private secret configurations.
The `system` package is stowed first to ensure `.stow-global-ignore` is in place before other packages.

### Branch Strategy

Branch-based profile management provides configuration flexibility without runtime complexity.

- **main branch**: Personal configurations for home use
- **shopify branch**: Work environment configurations (Shopify-specific tools and settings)
  - Rebase on main to pull in general improvements
  - Allow dev tools to modify files freely without affecting main
  - Push auto-generated changes without concern

**Switching contexts:**

```bash
git checkout shopify    # Switch to work environment
git checkout main       # Switch to personal environment
```

**Why branches instead of runtime profiles:**

- Full git version control for each configuration set
- Complete flexibility (different files, configs, templates, dependencies)
- Simpler workflow (standard git commands)
- No state management or profile tracking files
- Better collaboration (work branch shareable with team)
- Leverage git rebase to sync improvements between profiles

Runtime profile systems add unnecessary complexity for single-user dotfiles.
Branches provide superior flexibility with standard git tooling.

## Documentation Standards

- Use formal, minimal, reserved tone
- Use technically precise language
- Eliminate unnecessary words
- Avoid marketing language, exclamations, or enthusiasm
- Be direct and concise
- Focus on essential information only

## Code Standards

- Follow existing patterns and structure
- Maintain consistency with current implementations
- Use clear, descriptive variable names
- Include error handling where appropriate
- Keep functions focused and single-purpose
- Use long-form arguments for stow (e.g., `--verbose` not `-v`)
- Use POSIX-compatible short-form for coreutils (`-p`, `-r`, not `--parents`, `--recursive`)
  - BSD/macOS do not support GNU long-form arguments
  - Short forms work on all platforms
- Use explicit error handling instead of `set -e` (controlled failure handling)
- Enable bash safety features: `shopt -s nullglob extglob`

### Bash 3.2 Compatibility

Required for macOS default bash support.

**Prohibited features (Bash 4.0+):**

```bash
# ❌ Associative arrays
declare -A my_map
my_map[key]=value

# ✅ Use functions instead
get_value() {
    case "$1" in
        key1) echo "value1" ;;
        key2) echo "value2" ;;
    esac
}

# ❌ mapfile command
mapfile -t lines < file

# ✅ Use while-read loop
lines=()
while IFS= read -r line; do
    lines+=("$line")
done < file

# ❌ &>> redirect operator
command &>> file

# ✅ Use separate redirects
command > file 2>&1
```

**Testing Bash 3.2 compatibility:**

```bash
# Local CI test
./tests/run-local-ci.sh bash32

# Manual test with bash 3.2
docker run -it dotfiles-test-bash32 bash
```

## File Organization

- Package-specific files go in their respective directories (system/, git/, zsh/, tmux/, gh/, gnuplot/, bash/)
- Scripts (`dot`) remain in root
- Configuration files use dot-prefixed names
- `.gitignore` is project-specific, not managed by stow

### Stow Ignore Files

- **`system/.stow-global-ignore`**: Symlinked to `~/.stow-global-ignore`, contains universal patterns
  for all stow operations
- **Package `.stow-local-ignore`**: In each package directory (e.g., `git/.stow-local-ignore`),
  contains package-specific ignore patterns
- Template/secret/example files are ignored via `.stow-local-ignore` in each package

### Templates and Secrets

- Templates (`.template` files) contain placeholders for sensitive information
- Secret configs (`.secret` files) are git-ignored and contain actual sensitive values
- Example files (`.example` files) show format for secret configs
- **These files are NOT stowed** - ignored via package `.stow-local-ignore` files
- Installation script merges templates with secret configs during installation

### Platform-Specific Configs

- OS-specific configs use suffixes: `.bashrc.osx`, `.bashrc.linux`, `.zshrc.osx`, `.zshrc.linux`

## Logging System

The `dot` script uses symbol-based logging for clear, scannable output:

- `●` (blue) - Informational messages
- `✓` (green) - Success messages
- `⚠` (yellow) - Warnings
- `✗` (red) - Errors

Subcommand output is prefixed with `│` and colorized based on content:

- Red: error patterns (error, failed, fatal, cannot, unable)
- Yellow: warning patterns (warning, warn)
- Green: success patterns (success, ok, done, complete)
- Blue prefix: normal output

Status symbols are extracted to variables for consistency:

- `SYMBOL_SUCCESS="✓"` - Success indicator
- `SYMBOL_ERROR="✗"` - Error indicator
- `SYMBOL_WARNING="⚠"` - Warning indicator
- `SYMBOL_INFO="∙"` - Informational indicator (minimalist)

## Verbosity System

The `install` and `update` commands support 3 verbosity levels:

- **Level 0** (default): Task completion summary + errors/warnings
- **Level 1** (`-v`): Add package names and progress details
- **Level 2** (`-vv`): Show every file operation (symlinks, checks)

Flags can be stacked: `-v -v` or `--verbose --verbose` = level 2

Implementation uses `parse_verbosity()` to accumulate levels and helper functions to reduce duplication:

- `run_with_verbosity()` - Execute commands with appropriate output based on level
- `run_step()` - Execute numbered steps with consistent formatting
- `show_installation_summary()` - Display 5-line success summary (used by install/update)

The `health` command uses binary verbosity: table format (default) or detailed (`-v`).

## Helper Functions

The script uses helper functions to eliminate code duplication:

- `get_backup_stats()` - Returns backup count and size (used 3x)
- `count_orphaned_symlinks()` - Returns orphaned symlink count
- `show_installation_summary()` - Unified 5-line success message
- `show_tip()` / `show_tips()` - Consistent tip formatting
- `run_health_check()` - Unified health check section pattern (11 checks)
- `run_with_verbosity()` - Execute with verbosity-appropriate output
- `run_step()` - Execute numbered steps with error handling

When modifying commands, prefer using these helpers over duplicating logic.

## Validation

- All changes should pass validation script
- Symlinks must point to dotfiles repository
- Dependencies must be properly checked
- Backup functionality must be preserved

## Update Instructions

**This file must be updated whenever new guidance is provided during conversations.**

When adding new instructions:

- Maintain the formal, minimal tone
- Be technically precise
- Include only essential information
- Update the timestamp or version if needed

## Code Quality

- All Markdown files must pass markdownlint validation
- All Bash scripts must pass shellcheck validation
- Configuration files: `.markdownlint.yml`, `.shellcheckrc`
- Linting runs as prerequisite in CI before validation tests
- **Always run linting after making changes to verify code quality**

## CI/CD

- GitHub Actions workflow validates installation on Ubuntu and macOS
- Uses `apt-get` for stable package management in scripts
- Tests full installation pipeline including dependency checks
- Linting job must pass before validation jobs run

## Common Tasks

- Installation: `./dot install` (add `-v` or `-vv` for more detail)
- Update: `./dot update` (add `-v` or `-vv` for more detail)
- Status check: `./dot status`
- Health check: `./dot health` (add `-v` for detailed output)
- Linting: `markdownlint "**/*.md"` and `shellcheck dot`
- Package management: `stow --verbose --restow --dir=. --target=$HOME package_name`
- Backup location: `backups/dotfiles-backup-*` (timestamped directories)
- CI validation: `.github/workflows/validate.yml`

**Verbosity Examples:**

```bash
./dot install          # Clean summary
./dot install -v       # Show packages
./dot install -vv      # Show all files
./dot health           # Table format
./dot health -v        # Detailed checks
```

## Testing

### Local Testing

**Before committing:**

```bash
# Quick smoke tests (30 seconds)
./tests/smoke-test.sh
```

**Before pushing:**

```bash
# Full cross-platform tests (2-3 minutes, requires Docker or Podman)
./tests/run-local-ci.sh
```

### Testing Strategy

- **Smoke tests**: Fast validation of basic functionality and structure
- **Container tests**: Full installation on Ubuntu and Alpine (BSD-like)
- **GitHub Actions**: Final validation on real Ubuntu and macOS runners

### Why This Matters

Cross-platform compatibility issues (BSD vs GNU commands) are caught by:

1. Alpine tests (BusyBox = BSD-like coreutils)
2. GitHub Actions macOS runner (actual macOS)

Always run container tests before pushing to catch platform-specific issues early.

### Test Documentation

See `tests/README.md` for detailed testing framework documentation.

## Pull Request Workflow

For all code changes:

1. **Create Pull Request**: Use GitHub MCP to raise PR
2. **Request Copilot Review**: Use `mcp_github_request_copilot_review`
3. **Wait for CI**: Monitor CI status until passing
4. **Wait for Copilot Review**: Review Copilot feedback
5. **Address Issues**: Fix any problems identified
6. **Repeat**: Continue until both CI and Copilot approve
7. **Merge**: Only merge after both CI and Copilot are satisfied

This ensures code quality through automated testing and AI review.

## Monitoring CI and GitHub Actions

Use GitHub CLI (`gh`) to monitor CI status and troubleshoot failures.

### Check PR Status

```bash
# Quick status overview
gh pr checks <PR_NUMBER>

# View detailed check information with URLs
gh pr view <PR_NUMBER> --json statusCheckRollup --jq '.statusCheckRollup[] | "\(.name)\t\(.conclusion)\t\(.detailsUrl)"'

# Check overall PR status
gh pr view <PR_NUMBER> --json statusCheckRollup,state
```

### View CI Logs

```bash
# View logs for failed jobs only
gh run view <RUN_ID> --log-failed

# View logs for specific job
gh run view <RUN_ID> --log --job <JOB_ID>

# List recent workflow runs
gh run list --workflow=validate.yml --limit 5

# Watch run in real-time
gh run watch <RUN_ID>
```

### Common Patterns

**After pushing changes:**

```bash
# Wait for CI to start, then check status
sleep 30 && gh pr checks <PR_NUMBER>

# Watch run progress
gh run watch  # Watches latest run
```

**When CI fails:**

```bash
# Get failed job logs
gh run view --log-failed

# Re-run failed jobs (after fixing)
gh run rerun <RUN_ID> --failed
```

**Get run ID from PR:**

```bash
# Extract run ID from PR using gh and jq (portable)
gh pr view <PR_NUMBER> --json statusCheckRollup --jq '.statusCheckRollup[0].detailsUrl' | grep -oE '[0-9]+$'
```

### MCP GitHub Tools Limitations

While MCP GitHub tools provide rich PR/issue management:

- **Use `gh` CLI for CI monitoring**: MCP tools don't provide formatted log output
- **Use `gh` for workflow runs**: Real-time watching and log filtering unavailable via MCP
- **Use MCP for PR management**: Creating, updating, reviewing, merging PRs

**Best practice:** Combine both tools - MCP for PR operations, `gh` for CI monitoring.
