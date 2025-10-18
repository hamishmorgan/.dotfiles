# Agent Instructions

Instructions for AI agents working with this dotfiles repository.

## Table of Contents

- [Project Context](#project-context)
  - [Branch Strategy](#branch-strategy)
- [Dependencies](#dependencies)
- [Documentation Standards](#documentation-standards)
- [Code Standards](#code-standards)
  - [Error Handling Patterns](#error-handling-patterns)
  - [Bash 3.2 Compatibility](#bash-32-compatibility)
- [File Organization](#file-organization)
  - [Stow Ignore Files](#stow-ignore-files)
  - [Templates and Secrets](#templates-and-secrets)
  - [Platform-Specific Configs](#platform-specific-configs)
- [Logging System](#logging-system)
- [Verbosity System](#verbosity-system)
- [Helper Functions](#helper-functions)
- [Validation](#validation)
- [Update Instructions](#update-instructions)
- [Code Quality](#code-quality)
- [CI/CD](#cicd)
  - [CI Performance Optimization](#ci-performance-optimization)
- [Quick Reference](#quick-reference)
- [Common Tasks](#common-tasks)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Pull Request Workflow](#pull-request-workflow)
- [GitHub Integration](#github-integration)

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

**Documentation Structure:**

- **README.md**: User-facing documentation (installation, usage, features)
- **DEVELOPMENT.md**: Developer documentation (setup, workflow, testing, CI, architecture)
- **AGENTS.md**: AI agent instructions (this file - technical implementation guidance)
- **tests/README.md**: Testing framework documentation

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

## Dependencies

### Required Tools

- **stow**: GNU Stow 2.x+ (symlink management)
- **git**: 2.x+ (version control)
- **bash**: 3.2+ (script execution, macOS default is 3.2.57)

### Optional Tools

- **gh**: GitHub CLI (CI monitoring, PR management)
- **jq**: JSON processing (used with `gh` for CI status parsing)
- **docker** or **podman**: Container runtime for local CI testing
- **markdownlint-cli**: Markdown linting (or use `npx`)
- **shellcheck**: Bash script linting

### Version Requirements

Check versions:

```bash
bash --version      # Minimum: 3.2
stow --version      # Minimum: 2.0
git --version       # Minimum: 2.0
```

### Checking Dependencies

```bash
./dot status        # Shows missing dependencies and their installation status
```

### Platform-Specific Installation

**macOS:**

```bash
brew install stow git gh jq
brew install shellcheck markdownlint-cli
```

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install stow git gh jq
sudo apt-get install shellcheck
# Use npx for markdownlint: npx --yes markdownlint-cli@0.42.0
```

**Alpine:**

```bash
apk add stow git bash
# gh, jq available but optional for core functionality
```

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

### Error Handling Patterns

**Check command success:**

```bash
if ! command_name arg1 arg2; then
    log_error "Command failed: command_name"
    return 1
fi

# Alternative: capture and check exit status
if ! output=$(command_name 2>&1); then
    log_error "Command failed: $output"
    return 1
fi
```

**Validate required input:**

```bash
if [[ -z "$variable" ]]; then
    log_error "Variable 'variable' is required"
    return 1
fi

if [[ ! -f "$file_path" ]]; then
    log_error "File not found: $file_path"
    return 1
fi

if [[ ! -d "$directory" ]]; then
    log_error "Directory not found: $directory"
    return 1
fi
```

**Handle optional parameters with defaults:**

```bash
# Use parameter expansion for defaults
local verbosity="${1:-0}"
local target="${2:-$HOME}"

# Or explicit checks
if [[ -z "$optional_arg" ]]; then
    optional_arg="default_value"
fi
```

**Function return patterns:**

```bash
# Return 0 for success, 1 for failure
function_name() {
    # ... logic ...
    if [[ condition ]]; then
        return 0  # Success
    else
        return 1  # Failure
    fi
}

# Check function result
if function_name; then
    log_success "Operation completed"
else
    log_error "Operation failed"
    exit 1
fi
```

**Avoid `set -e`:**

Do not use `set -e` (exit on error). Use explicit error checking for controlled failure handling.
This allows proper cleanup, logging, and user-friendly error messages.

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

Before committing changes, verify:

**1. Linting passes:**

```bash
markdownlint "**/*.md"
shellcheck dot tests/**/*.sh
```

**2. Smoke tests pass (30 seconds):**

```bash
./tests/smoke-test.sh
```

**3. Full CI passes (2-3 minutes):**

```bash
./tests/run-local-ci.sh
```

**What gets validated:**

- Symlinks point to dotfiles repository (not copies)
- Required dependencies are installed
- Backup functionality works correctly
- Cross-platform compatibility (Ubuntu, Alpine, macOS)
- Bash 3.2 compatibility
- Package stowing completes without errors

## Update Instructions

**This file must be updated whenever new guidance is provided during conversations.**

### Triggers for Updates

Update AGENTS.md when:

- **New patterns emerge** from multi-iteration problem-solving (like CI optimization)
- **Significant bugs fixed** that reveal broader lessons (dependency detection, caching)
- **Performance optimizations** with measured results
- **Tool/workflow discoveries** (like `gh` CLI for CI monitoring)
- **Cross-platform issues resolved** (macOS vs Linux compatibility)
- **New helper functions** or code patterns established
- **Build/CI configuration changes** that set precedents

### When Adding Instructions

- Maintain the formal, minimal tone
- Be technically precise
- Include only essential information
- **Include measured data** when available (performance improvements, timing)
- **Document both what worked and what didn't** (negative results prevent repeated mistakes)
- Reference the issue/PR that led to the guidance

### Update Frequency

Update AGENTS.md for both major and minor changes as they occur. Do not batch changes.

Examples of minor updates:

- Clarifications that prevent common mistakes
- Tool usage tips discovered during work
- Small workflow improvements
- Command examples that prove useful

Immediate updates ensure the document stays current and prevents repeated mistakes.

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

### CI Performance Optimization

Key learnings from CI optimization work (Issue #42, PR #58):

**Caching Strategies:**

- **Homebrew**: Don't cache. Bottles install faster than cache save/restore overhead.
- **apt packages**: Use user-writable cache (`~/.apt-cache`) to avoid permission issues:

  ```yaml
  - name: Configure apt caching
    run: |
      mkdir -p ~/.apt-cache/archives/partial
      sudo mkdir -p /etc/apt/apt.conf.d
      echo "Dir::Cache::Archives \"$HOME/.apt-cache/archives\";" | sudo tee /etc/apt/apt.conf.d/99user-cache
  ```

- **npm tools**: Use `npx` with version pinning instead of global install:

  ```yaml
  npx --yes markdownlint-cli@0.42.0 "**/*.md"
  ```

- **Stable cache keys**: Use package names, not file hashes to reduce cache churn.
- **Clean up lock files**: Remove root-owned locks before cache save:

  ```yaml
  - name: Clean up apt cache lock files
    if: always()
    run: rm -rf ~/.apt-cache/archives/lock ~/.apt-cache/archives/partial
  ```

**Performance Insights:**

- `apt-get update` is the main bottleneck (~8-9s per job)
- Separate into dedicated step for timing visibility
- Skip installing pre-installed packages (shellcheck on GitHub runners)
- Parallel job execution reduces wall-clock time
- Verbose test output (`-vv`) aids debugging without performance cost

**Measured Results:**

Optimizations reduced CI time from 8-12 minutes to ~1 minute (92% improvement):

- Linting: 90s → 15s (83% faster)
- Smoke: 30s → 6s (80% faster)
- Ubuntu: 120s → 28s (77% faster)
- Bash 3.2: 120s → 32s (73% faster, cache miss)
- macOS: 180s → 26s (86% faster)

## Quick Reference

| Task | Command | Time |
|------|---------|------|
| Install dotfiles | `./dot install` | 1-2m |
| Update dotfiles | `./dot update` | 1-2m |
| Check health | `./dot health` | instant |
| Check status | `./dot status` | instant |
| Smoke test | `./tests/smoke-test.sh` | 30s |
| Full local CI | `./tests/run-local-ci.sh` | 2-3m |
| Lint Markdown | `markdownlint "**/*.md"` | 5s |
| Lint Bash | `shellcheck dot tests/**/*.sh` | 5s |
| Monitor CI | `gh pr checks <PR>` | instant |
| View CI logs | `gh run view --log-failed` | instant |

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

## Troubleshooting

### Symlink Issues

**Broken or orphaned symlinks:**

```bash
./dot health           # Identify broken symlinks
./dot health -v        # Detailed information

# Remove broken symlinks
find ~ -maxdepth 1 -type l ! -exec test -e {} \; -delete

# Re-stow package
stow --verbose --restow --dir=. --target=$HOME package_name
```

**Stow fails with "existing target is not owned by stow":**

```bash
# Back up conflicting file
mv ~/.conflicting_file ~/.conflicting_file.backup

# Re-run stow
stow --verbose --restow --dir=. --target=$HOME package_name

# Or use ./dot install which handles conflicts
./dot install -vv
```

### Installation Problems

**Missing dependencies:**

```bash
./dot status           # Lists missing dependencies
```

Install missing tools based on platform:

```bash
# macOS
brew install stow git

# Ubuntu/Debian
sudo apt-get install stow git

# Alpine
apk add stow git
```

**Permission errors:**

Ensure `$HOME` is writable. Stow creates symlinks in `$HOME` pointing to files in the dotfiles repository.

### CI/CD Issues

**CI fails on platform-specific commands:**

1. Check Alpine test results (BSD-like coreutils compatibility)
2. Verify short-form arguments used for coreutils (`-p`, `-r`)
3. Test locally: `./tests/run-local-ci.sh alpine`

**CI fails on macOS Bash compatibility:**

1. Test Bash 3.2 compatibility: `./tests/run-local-ci.sh bash32`
2. Avoid Bash 4.0+ features (associative arrays, mapfile, &>>)
3. See Bash 3.2 Compatibility section for alternatives

**CI caching issues:**

Clear GitHub Actions cache if persistent failures occur:

```bash
# List caches
gh cache list

# Delete specific cache
gh cache delete <CACHE_ID>
```

### Rollback Procedures

**Restore from backup:**

```bash
# List available backups
ls -lt backups/

# Restore specific backup (replaces current symlinks)
cp -r backups/dotfiles-backup-YYYYMMDD-HHMMSS/* ~/
```

**Undo stow operations:**

```bash
# Remove all symlinks for specific package
stow --verbose --delete --dir=. --target=$HOME package_name

# Remove all dotfiles symlinks
for pkg in system git zsh tmux gh gnuplot bash; do
    stow --verbose --delete --dir=. --target=$HOME "$pkg"
done
```

**Restore repository to clean state:**

```bash
git status             # Check for uncommitted changes
git stash              # Stash changes if needed
git checkout main      # Return to main branch
git pull               # Update to latest
./dot update           # Re-apply dotfiles
```

## Pull Request Workflow

For all code changes:

1. **Create Pull Request**: Use GitHub MCP to raise PR
2. **Request Copilot Review**: Use `mcp_github_request_copilot_review`
3. **Wait for CI**: Monitor CI status until passing
4. **Wait for Copilot Review**: Review Copilot feedback
5. **Address Issues**: Fix any problems identified
6. **Repeat**: Continue until both CI and Copilot approve
7. **Update AGENTS.md**: Document new patterns, optimizations, or lessons learned
8. **Merge**: Only merge after both CI and Copilot are satisfied

This ensures code quality through automated testing and AI review.

**Note:** The PR template includes an AGENTS.md update checklist to remind about documentation.

## GitHub Integration

GitHub can be accessed through both MCP tools and `gh` CLI. Each has strengths for different tasks.

### When to Use Each Tool

**Use MCP GitHub tools for:**

- Creating pull requests (`mcp_github_create_pull_request`)
- Updating PRs and issues (`mcp_github_update_pull_request`)
- Requesting reviews (`mcp_github_request_copilot_review`)
- Managing PR comments and reviews
- Creating and managing issues
- Repository operations (fork, create, branches)
- Searching code, issues, PRs across GitHub

**Use `gh` CLI for:**

- Monitoring CI status in real-time
- Viewing workflow logs with formatting
- Watching test runs as they execute
- Re-running failed jobs
- Quick status checks during iteration

**Common mistake:** Attempting a task with only one tool. If MCP doesn't provide the needed
output format or `gh` lacks the functionality, try the other tool. Both can read/write GitHub
data but have different interfaces and capabilities.

### MCP GitHub Tools

**Create and manage PRs:**

```bash
# Use MCP functions in Cursor
mcp_github_create_pull_request
mcp_github_update_pull_request
mcp_github_request_copilot_review
mcp_github_merge_pull_request
```

**Search and explore:**

```bash
# Search across all of GitHub
mcp_github_search_code         # Find code patterns
mcp_github_search_issues       # Find relevant issues
mcp_github_search_pull_requests # Find PRs by criteria
```

### GitHub CLI (`gh`)

**Monitor CI status:**

```bash
# Quick status overview
gh pr checks <PR_NUMBER>

# View detailed check information with URLs
gh pr view <PR_NUMBER> --json statusCheckRollup --jq '.statusCheckRollup[] | "\(.name)\t\(.conclusion)\t\(.detailsUrl)"'

# Check overall PR status
gh pr view <PR_NUMBER> --json statusCheckRollup,state
```

**View CI logs:**

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

**Common patterns:**

```bash
# After pushing changes
sleep 30 && gh pr checks <PR_NUMBER>
gh run watch  # Watch latest run

# When CI fails
gh run view --log-failed
gh run rerun <RUN_ID> --failed

# Get run ID from PR (portable)
gh pr view <PR_NUMBER> --json statusCheckRollup --jq '.statusCheckRollup[0].detailsUrl' | grep -oE '[0-9]+$'
```

### Best Practice

Use both tools complementarily:

- **MCP**: PR lifecycle management (create, update, review, merge)
- **gh**: CI monitoring and debugging (status, logs, re-runs)

When one tool doesn't provide what you need, try the other before concluding the task is impossible.
