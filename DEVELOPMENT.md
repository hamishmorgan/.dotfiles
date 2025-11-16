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

**Branch:** Single `main` branch. Machine-specific configs use `.local` files (git-ignored).

**Workflow:** Create feature branch, make changes, test (`./dev/lint && ./dev/test`), create PR, iterate.

**Commits:** Use [conventional commits](https://www.conventionalcommits.org/) - `type(scope): description`

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution workflow and
[.cursor/rules/pull-request-workflow.mdc](.cursor/rules/pull-request-workflow.mdc) for PR process.

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

**Quick workflow:**

```bash
./dev/lint-shell           # Fast (~5s)
./dev/lint && ./dev/test   # Before commit (~1m)
./dev/check                # Before push (~3-4m)
```

**Test categories:** Regression (one per bug), unit, integration, contract.
See [tests/README.md](tests/README.md) for comprehensive testing documentation.

### Writing Tests

**Pattern:** Write failing regression test before fixing bugs.
See [tests/README.md](tests/README.md) and [.cursor/rules/testing-workflow.mdc](.cursor/rules/testing-workflow.mdc)
for comprehensive testing documentation and TDD patterns.

### Local CI Testing

Run cross-platform tests locally using Docker/Podman:

```bash
# Test all platforms (comprehensive, ~6-9 minutes)
./dev/ci
# or
./dev/ci all

# Test single platform for quick iteration (~2-3 minutes)
./dev/ci ubuntu      # Quick Ubuntu check
./dev/ci alpine      # BSD compatibility check
./dev/ci bash32      # macOS compatibility check

# Keep test images for debugging
./dev/ci all --no-cleanup
```

**Platform selection:**

- **`ubuntu`**: Ubuntu 22.04 (matches GitHub Actions environment)
- **`alpine`**: Alpine Linux (BSD-like coreutils, catches macOS compatibility issues)
- **`bash32`**: Bash 3.2 (macOS default bash version)
- **`all`**: All platforms (comprehensive validation)

**When to use:**

- Single platform: During development for quick iteration
- All platforms: Before pushing to GitHub for comprehensive validation

See [tests/README.md](tests/README.md) for detailed testing documentation.

---

## Continuous Integration

**CI workflow:** Linting, smoke tests, BATS tests (ubuntu/macos), full validation (3 platforms), merge check.

**Total time:** ~1 minute (down from 8-12 minutes via optimizations)

**Monitoring:** `gh pr checks <PR>`, `gh run view --log-failed`

See [.cursor/rules/ci-cd.mdc](.cursor/rules/ci-cd.mdc) for comprehensive CI documentation and optimization patterns.

---

## Linting

```bash
./dev/lint              # All (~10s)
./dev/lint-shell        # Shellcheck (~5s)
./dev/lint-markdown     # Markdownlint (~5s)
```

**Configuration:** `.shellcheckrc`, `.markdownlint.yml`

---

## Debugging

**Verbose execution:** `./dot install -vv` or `bash -x ./dot install`

**Diagnostics:** `./dot health -v` for detailed checks, `./dot status` for quick overview

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
├── tmp/                  # Temporary files and proposals (git-ignored)
│   └── *PROPOSAL*.md     # Development proposals (not committed)
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

- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Contribution guidelines
- **[COMMANDS.md](COMMANDS.md)** - Complete command reference
- **[README.md](README.md)** - User documentation
- **[AGENTS.md](AGENTS.md)** - AI agent instructions
- **[tests/README.md](tests/README.md)** - Testing framework
- **[.cursor/rules/](.cursor/rules/)** - Workflow procedures

---

## Quick Reference

Task | Command | Time
------|---------|------
Install dotfiles | `./dot install` | 1-2m
Update dotfiles | `./dot update` | 1-2m
Check health | `./dot health` | instant
Check status | `./dot status` | instant
Smoke test | `./tests/smoke-test.sh` | 30s
Full local CI | `./dev/ci` or `./dev/ci all` | 6-9m
Single platform CI | `./dev/ci ubuntu, alpine, or bash32` | 2-3m
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
