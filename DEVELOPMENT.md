# Development Guide

Developer documentation for the .dotfiles repository.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Git Workflow](#git-workflow)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Continuous Integration](#continuous-integration)
- [Linting](#linting)
- [Debugging](#debugging)
- [Release Process](#release-process)
- [Architecture](#architecture)
- [Additional Resources](#additional-resources)
- [Quick Reference](#quick-reference)
- [Questions](#questions)

---

## Getting Started

### Prerequisites

**Required:**

- Git 2.0+
- Bash 3.2+ (macOS compatible)
- GNU Stow 2.3+

**Required (for development):**

- bats (automated testing framework)
- bats-assert (assertion library)
- bats-support (helper library)
- bats-file (file assertion library)
- shellcheck (bash linting)

**Optional (for development):**

- Docker or Podman (for local CI)
- markdownlint-cli (markdown linting)
- gh (GitHub CLI for PR management)
- jq (JSON processing for CI status)

### Clone for Development

```bash
# Fork repository on GitHub first

# Clone your fork
git clone git@github.com:YOUR_USERNAME/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Add upstream remote
git remote add upstream git@github.com:hamishmorgan/.dotfiles.git

# Initialize submodules
git submodule update --init --recursive
```

---

## Development Environment

### Recommended Tools

**Ubuntu/Debian:**

```bash
sudo apt-get update
sudo apt-get install git stow bats shellcheck nodejs npm
# BATS helper libraries
sudo apt-get install bats-assert bats-support bats-file
# Use npx for markdownlint (no global install needed)
npx --yes markdownlint-cli@0.42.0 "**/*.md"
```

**macOS:**

```bash
brew install git stow bats-core shellcheck markdownlint-cli gh jq
# BATS helper libraries (included with bats-core on Homebrew)
# Or install separately if needed:
# brew install bats-assert bats-support bats-file
```

### Editor Setup

**VS Code:**

```json
{
  "shellcheck.enable": true,
  "shellcheck.run": "onSave",
  "[markdown]": {
    "editor.formatOnSave": true
  }
}
```

**Vim/Neovim:**

```vim
" ALE linting
let g:ale_linters = {
\   'sh': ['shellcheck'],
\   'markdown': ['markdownlint'],
\}
```

---

## Git Workflow

### Branch Strategy

- **`main`**: Personal configurations (stable)
- **`shopify`**: Work environment configurations
  - Rebase on main to pull improvements
  - Allow dev tools to modify freely

**Why branches instead of runtime profiles:**

- Full git version control for each configuration set
- Complete flexibility (different files, configs, templates, dependencies)
- Simpler workflow (standard git commands)
- No state management or profile tracking files
- Better collaboration (work branch shareable with team)
- Leverage git rebase to sync improvements between profiles

### Feature Development

```bash
# Create feature branch from main
git checkout main
git pull upstream main
git checkout -b feature/your-feature

# Make changes and commit
git add .
git commit -m "feat: add your feature"

# Keep up to date with main
git fetch upstream
git rebase upstream/main

# Push to your fork
git push origin feature/your-feature
```

### Commit Message Convention

Follow conventional commits format:

```text
type(scope): brief description

Longer description if needed.

- Bullet points for details
- Multiple changes listed

Benefits:
- Enables automated changelog generation
- Improves commit history searchability
- Supports semantic versioning and release notes tooling
```

**Types:**

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `perf`: Performance improvements
- `test`: Test additions/changes
- `chore`: Maintenance tasks
- `ci`: CI/CD changes

**Examples:**

```bash
git commit -m "feat(zsh): add git status to prompt"
git commit -m "fix(install): handle missing secret files gracefully"
git commit -m "docs(readme): add manual installation section"
git commit -m "refactor(dot): extract helper functions for verbosity"
```

### Pull Request Process

1. **Create feature branch** from main
2. **Make changes** following code standards
3. **Test locally:**

   ```bash
   ./tests/smoke-test.sh
   ./tests/run-local-ci.sh
   ```

4. **Create PR** via GitHub
5. **Request Copilot review:**

   ```bash
   # Using GitHub CLI or MCP
   gh pr create
   ```

6. **Wait for CI** to pass
7. **Address feedback** from Copilot and CI
8. **Iterate** until approved
9. **Update AGENTS.md** if adding new patterns or learnings
10. **Merge** only after CI and review pass

---

## Code Standards

### Bash Style Guide

**Compatibility:**

- Target bash 3.2+ (macOS compatible)
- No associative arrays (bash 4.0+ only)
- No `mapfile` (bash 4.0+ only)
- Use `while read` loops instead

**Prohibited Bash 4.0+ features:**

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

**Command-line arguments:**

- Use long-form for stow: `--verbose`, `--restow`, `--target`
- Use POSIX short-form for coreutils: `-p`, `-r` (BSD/macOS don't support long-form)

**Error handling:**

- NO `set -e` (use explicit error checking)
- Check command exit status with `if ! command; then`
- Validate required parameters at function start
- Return 0 for success, 1 for failure
- Log errors with descriptive messages

**Example error handling:**

```bash
function_name() {
    local required_arg="$1"
    
    # Validate required input
    if [[ -z "$required_arg" ]]; then
        log_error "Parameter 'required_arg' is required"
        return 1
    fi
    
    # Check command success
    if ! some_command "$required_arg"; then
        log_error "Command failed: some_command"
        return 1
    fi
    
    return 0
}
```

**Code quality:**

- Use `shopt -s nullglob extglob` for safety
- Use descriptive variable names
- Keep functions focused and single-purpose
- Extract common patterns to helper functions
- Add comments for non-obvious logic

### Documentation Style

- Use formal, minimal, reserved tone
- Use technically precise language
- Eliminate unnecessary words
- Avoid marketing language or exclamations
- Be direct and concise
- Focus on essential information only

---

## Testing

### Development Workflow Commands

**Recommended workflow using `dev/` commands:**

```bash
# Setup development environment (first time)
./dev/setup

# Fast iteration (shell code changes)
./dev/lint-shell        # Just shellcheck (~5s)

# Before commit
./dev/lint && ./dev/test   # Lint + smoke + BATS (~1m)

# Before push
./dev/check             # Complete validation (~3-4m)
```

### Atomic Test Commands

**Individual test operations:**

```bash
# Linting
./dev/lint-markdown     # Markdown files only (~5s)
./dev/lint-shell        # Shell scripts only (~5s)
./dev/lint              # All linting (~10s)

# Testing
./dev/smoke             # Fast structural validation (~30s)
./dev/bats              # All BATS test suites (~30s)
./dev/test              # Smoke + BATS (~1m)

# CI
./dev/ci                # Full local CI (~2-3m)
./dev/ci ubuntu         # Test specific platform
./dev/ci alpine         # Alpine (BusyBox/BSD-like)
./dev/ci bash32         # Bash 3.2 compatibility
```

### Legacy Test Scripts

For backward compatibility (CI uses these):

```bash
./tests/smoke-test.sh      # Redirects to ./dev/smoke
./tests/run-bats.sh        # Redirects to ./dev/bats
./tests/run-local-ci.sh    # Redirects to ./dev/ci
```

### Direct BATS Commands

Run specific test suites directly:

```bash
bats tests/regression/   # Bug regression tests
bats tests/unit/         # Unit tests
bats tests/integration/  # Integration tests
bats tests/contract/     # Output validation
```

### Test Framework Organization

The testing framework uses **BATS** (Bash Automated Testing System) with four test categories:

```text
tests/
├── regression/        # Bug prevention (one test per bug)
├── unit/             # Function-level tests (isolated)
├── integration/      # Command-level tests (end-to-end)
├── contract/         # Output format validation
├── test_helper/      # Shared helper functions
└── TEST_FRAMEWORK.md # Detailed documentation
```

**Test Distribution:**

- Regression: One test per fixed bug
- Unit: 70% of tests (function-level)
- Integration: 25% of tests (command-level)
- Contract: 5% of tests (output validation)

### Writing Tests

**Regression tests (most important):**

Create a failing test BEFORE fixing a bug:

```bash
# tests/regression/test_issue_XX.bats
@test "Issue #XX: describe the bug" {
    # Setup that reproduces bug
    create_mock_backups 15 1
    
    run ./dot health
    
    # Assertion that fails on the bug
    assert_output_not_contains "using 0MB"
}
```

Pattern:

1. Write test that reproduces bug (test fails)
2. Fix the bug in code
3. Run test again (test passes)
4. Commit test + fix together

**Unit tests:**

Test individual functions with various inputs:

```bash
# tests/unit/test_backup_functions.bats
@test "get_backup_stats counts backups correctly" {
    create_mock_backups 5 1
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    [ "$count" = "5" ]
}
```

**Integration tests:**

Test complete command workflows:

```bash
# tests/integration/test_health.bats
@test "health command exits successfully" {
    run ./dot health
    [ "$status" -eq 0 ]
}
```

### Test Helper Functions

Available in `tests/test_helper/common.bash`:

- `setup_test_dotfiles` - Create isolated test environment
- `create_mock_backups COUNT SIZE_MB` - Generate test data
- `assert_output_contains "pattern"` - Verify output
- `assert_output_not_contains "pattern"` - Verify exclusion

### Testing Strategy

- **BATS tests**: Automated regression, unit, integration testing
- **TDD for bugs**: Write failing test before fix (mandatory)
- **Smoke tests**: Fast structural validation
- **Container tests**: Cross-platform compatibility (BSD vs GNU)
- **GitHub Actions**: Final validation on Ubuntu and macOS

### Why This Matters

**BATS tests catch logic bugs:**

- Variable name typos (Issue #66: `$backup_size` vs `$backup_size_kb`)
- Calculation errors
- Output format changes
- Unintended behavior changes

**Cross-platform tests catch compatibility:**

- BSD vs GNU command differences (Alpine tests)
- macOS-specific issues (GitHub Actions)

**Required:** Write regression test for every bug fix.

### Test Implementation

**Basic test structure:**

```bash
#!/usr/bin/env bats

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
}

teardown() {
    teardown_test_dotfiles
}

@test "descriptive test name" {
    # Arrange: Set up test conditions
    create_mock_backups 5 1
    
    # Act: Run the code being tested  
    run ./dot health
    
    # Assert: Verify results
    assert_success
    assert_output --partial "5 backups"
}
```

**Available assertions** (from bats-assert, bats-support, bats-file):

- `assert_success` / `assert_failure` - Exit codes
- `assert_equal "expected" "actual"` - Exact match
- `assert_output --partial "text"` - Substring match
- `assert_output --regexp "pattern"` - Regex match
- `refute_output --partial "text"` - Does not contain
- `assert_file_exist "path"` - File checks
- `assert_dir_exist "path"` - Directory checks

**Custom helpers** (from `tests/test_helper/common.bash`):

- `setup_test_dotfiles` - Create isolated test environment
- `create_mock_backups COUNT SIZE_MB` - Generate test backups
- `source_dot_script` - Load dot script functions
- `assert_in_range VALUE MIN MAX` - Numeric validation

**Test isolation principles:**

- Each test must be independent  
- Use `setup()` / `teardown()` hooks
- Don't rely on test execution order
- Tests should pass when run individually or in suite

---

## Continuous Integration

### CI Pipeline

GitHub Actions workflow validates installation on multiple platforms:

- **Linting Job**: Validates Markdown and Bash scripts before tests
- **Smoke Tests**: Quick validation of basic functionality
- **Ubuntu Validation**: Full installation on Ubuntu
- **macOS Validation**: Full installation on macOS
- **Bash 3.2 Validation**: Explicit testing with Bash 3.2

### Workflow Configuration

Workflow file: `.github/workflows/validate.yml`

**Key features:**

- Parallel job execution
- Linting as prerequisite for all tests
- Cross-platform testing
- Bash 3.2 compatibility verification
- Configuration syntax validation

### CI Performance

Optimizations implemented (Issue #42, PR #58):

- **Linting**: ~15s
- **Smoke Tests**: ~6s
- **Ubuntu Validation**: ~28s
- **Bash 3.2 Validation**: ~32s
- **macOS Validation**: ~26s

**Total CI time**: ~1 minute (down from 8-12 minutes)

### Monitoring CI

**Check PR status:**

```bash
# Quick status overview
gh pr checks <PR_NUMBER>

# View detailed check information
gh pr view <PR_NUMBER> --json statusCheckRollup

# Watch run in real-time
gh run watch
```

**View logs:**

```bash
# View logs for failed jobs only
gh run view --log-failed

# List recent workflow runs
gh run list --workflow=validate.yml --limit 5
```

**Common workflow:**

```bash
# After pushing changes
sleep 30 && gh pr checks <PR_NUMBER>

# If CI fails
gh run view --log-failed

# Re-run failed jobs
gh run rerun <RUN_ID> --failed
```

### CI Best Practices

**Before pushing:**

```bash
# Ensure local tests pass
./tests/smoke-test.sh
./tests/run-local-ci.sh

# Verify linting
shellcheck dot
markdownlint "**/*.md"
```

**Common CI failures:**

- Shellcheck warnings → Fix code style
- Markdownlint errors → Fix markdown formatting
- Installation failures → Test locally first
- Platform-specific issues → Run local CI (alpine test catches BSD issues)

### Caching Strategies

Key learnings from CI optimization:

**What to cache:**

- `apt` packages: Use user-writable cache to avoid permission issues
- Cache key should use package names, not file hashes (reduces churn)

**What NOT to cache:**

- Homebrew bottles: Install faster than cache save/restore overhead
- npm tools: Use `npx` with version pinning instead

**apt cache configuration:**

```yaml
- name: Configure apt caching
  run: |
    mkdir -p ~/.apt-cache/archives/partial
    sudo mkdir -p /etc/apt/apt.conf.d
    echo "Dir::Cache::Archives \"$HOME/.apt-cache/archives\";" | sudo tee /etc/apt/apt.conf.d/99user-cache

- name: Clean up apt cache lock files
  if: always()
  run: rm -rf ~/.apt-cache/archives/lock ~/.apt-cache/archives/partial
```

---

## Linting

### Development Commands

**Recommended workflow:**

```bash
# Run all linting
./dev/lint              # Markdown + Shell (~10s)

# Individual linters
./dev/lint-markdown     # Just Markdown files (~5s)
./dev/lint-shell        # Just shell scripts (~5s)
```

### Shellcheck

Lints bash scripts for common issues:

```bash
# Via dev command (recommended)
./dev/lint-shell

# Direct invocation
shellcheck dot bash/.bashrc* bash/.bash_profile zsh/.zshrc* zsh/.zprofile tests/**/*.sh

# Check with source following
shellcheck -x dot
```

**Configuration:** `.shellcheckrc`

Disables acceptable patterns for dotfiles:

```bash
disable=SC1090  # Can't follow non-constant source
disable=SC1091  # Not following external files
disable=SC2034  # Variables unused (used by frameworks)
disable=SC2231  # Quote expansions in for loop globs
```

### Markdownlint

Lints markdown documentation:

```bash
# Via dev command (recommended)
./dev/lint-markdown

# Direct invocation
npx --yes markdownlint-cli@0.42.0 "**/*.md"

# Fix auto-fixable issues
npx --yes markdownlint-cli@0.42.0 "**/*.md" --fix
```

**Configuration:** `.markdownlint.yml`

```yaml
# Project-specific rules
MD013: false  # Line length
MD033: false  # HTML allowed
```

### Pre-commit Hooks

Optionally install pre-commit hooks (see #38):

```bash
# Install pre-commit framework
pip install pre-commit

# Install hooks
pre-commit install

# Run manually
pre-commit run --all-files
```

---

## Debugging

### Verbose Execution

```bash
# Show all operations
./dot install -vv

# Trace bash execution
bash -x ./dot install

# Debug specific command
set -x
./dot health
set +x
```

### Common Issues

**Symlink conflicts:**

```bash
# Check existing files
ls -la ~ | grep -v "^l"

# Remove conflict and retry
mv ~/.gitconfig ~/.gitconfig.backup
./dot install
```

**Stow errors:**

```bash
# Dry run to see what would happen
stow --no --verbose --restow --dir=. --target=$HOME git

# Force adoption of existing files (careful!)
stow --adopt --verbose --restow --dir=. --target=$HOME git
```

**Submodule issues:**

```bash
# Reinitialize submodules
git submodule deinit --all
git submodule update --init --recursive

# Update submodule URLs
git submodule sync
git submodule update --init --recursive
```

### Health Checks

```bash
# Run comprehensive diagnostics
./dot health

# Verbose health check (detailed output)
./dot health -v

# Check dependency and backup status
./dot status
```

---

## Release Process

### Version Tracking

Version is embedded in `dot` script:

```bash
readonly DOT_VERSION="1.2.0"
```

### Creating Releases

```bash
# Update version in dot script
vim dot  # Update DOT_VERSION

# Commit version bump
git add dot
git commit -m "chore: bump version to 1.2.0"

# Tag release
git tag -a v1.2.0 -m "Release v1.2.0"

# Push to GitHub
git push origin main --tags
```

### Changelog

See #37 for automated changelog generation proposal.

Manual changelog updates in release notes:

```markdown
## [1.2.0] - 2025-01-15

### Added

- New feature X
- Enhancement Y

### Fixed

- Bug fix Z

### Changed

- Refactored component A
```

---

## Architecture

### Project Structure

```text
.dotfiles/
├── dot                    # Main management script
├── README.md             # User documentation
├── DEVELOPMENT.md        # Developer documentation (this file)
├── AGENTS.md             # AI agent instructions
├── LICENSE               # MIT license
├── .github/
│   ├── workflows/
│   │   └── validate.yml  # CI configuration
│   └── pull_request_template.md
├── tests/
│   ├── smoke-test.sh     # Quick validation
│   ├── run-local-ci.sh   # Container orchestration
│   ├── README.md         # Testing documentation
│   ├── lib/              # Shared test utilities
│   │   ├── common.sh
│   │   ├── create-secrets.sh
│   │   ├── run-installation.sh
│   │   └── verify-health.sh
│   └── docker/
│       ├── Dockerfile.ubuntu
│       ├── Dockerfile.alpine
│       ├── Dockerfile.bash32
│       └── test-in-container.sh
├── backups/              # Installation backups (git-ignored)
├── system/               # System-wide configs
│   └── .stow-global-ignore
├── git/                  # Git configuration package
│   ├── .gitconfig.template
│   ├── .gitconfig.secret.example
│   ├── .gitconfig.secret      # git-ignored
│   └── .stow-local-ignore
├── zsh/                  # Zsh configuration package
│   ├── .zshrc
│   ├── .zprofile
│   ├── .zshrc.osx
│   ├── .zshrc.linux
│   ├── .oh-my-zsh/       # Submodule
│   └── .stow-local-ignore
├── tmux/                 # Tmux configuration package
├── gh/                   # GitHub CLI configuration
│   └── .config/gh/
│       ├── config.yml.template
│       ├── config.yml.secret.example
│       ├── config.yml.secret  # git-ignored
│       └── .stow-local-ignore
├── gnuplot/              # Gnuplot configuration
└── bash/                 # Bash configuration package
    ├── .bashrc
    └── .bash_profile
```

### Key Components

**dot script:**

- Main entry point
- Command routing (`install`, `update`, `health`, `status`)
- Installation/update logic
- Health checks (11 categories)
- Backup management
- Template processing and secret merging
- Verbosity system (0, 1, 2)

**Packages:**

- Self-contained configuration units
- Managed by GNU Stow
- Platform-specific variants (`.osx`, `.linux`)
- Template/secret separation (`.template`, `.secret`, `.secret.example`)
- Local ignore files (`.stow-local-ignore`)

**Testing:**

- Smoke tests for quick validation
- Container tests for cross-platform (Ubuntu, Alpine, Bash 3.2)
- CI for automated validation on real runners

### Design Principles

1. **Bash 3.2 Compatible**: Works on macOS out of the box
2. **Stow-Based**: Standard tool, not custom solution
3. **Template/Secret Separation**: Public templates, private secrets
4. **Modular Packages**: Independent, reusable units
5. **Cross-Platform**: Linux and macOS support
6. **Rollback-Safe**: Automatic backups before changes
7. **Verbose Levels**: 0 (quiet), 1 (progress), 2 (detail)
8. **Helper Functions**: Eliminate code duplication
9. **Explicit Error Handling**: No `set -e`, controlled failure handling

### Helper Functions

The script uses helper functions to eliminate duplication:

- `get_backup_stats()` - Returns backup count and size
- `count_orphaned_symlinks()` - Returns orphaned symlink count
- `show_installation_summary()` - Unified 5-line success message
- `show_tip()` / `show_tips()` - Consistent tip formatting
- `run_health_check()` - Unified health check section pattern
- `run_with_verbosity()` - Execute with verbosity-appropriate output
- `run_step()` - Execute numbered steps with error handling
- `parse_verbosity()` - Parse and accumulate verbosity flags

When modifying commands, prefer using these helpers over duplicating logic.

---

## Additional Resources

- **Testing Guide**: `tests/README.md`
- **AI Agent Instructions**: `AGENTS.md`
- **Code Standards**: See [Code Standards](#code-standards)
- **User Documentation**: `README.md`
- **Contribution Guide**: See #46 for `CONTRIBUTING.md` proposal

---

## Quick Reference

Task | Command | Time
------|---------|------
Install dotfiles | `./dot install` | 1-2m
Update dotfiles | `./dot update` | 1-2m
Check health | `./dot health` | instant
Check status | `./dot status` | instant
Smoke test | `./tests/smoke-test.sh` | 30s
Full local CI | `./tests/run-local-ci.sh` | 2-3m
Lint Markdown | `markdownlint "**/*.md"` | 5s
Lint Bash | `shellcheck dot` | 5s
Monitor CI | `gh pr checks <PR>` | instant
View CI logs | `gh run view --log-failed` | instant

---

## Questions?

- Open an issue for bugs or feature requests
- Check existing issues for answers
- Review `AGENTS.md` for comprehensive guidelines
- See `README.md` for user-facing documentation
