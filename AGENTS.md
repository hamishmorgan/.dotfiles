# Agent Instructions

Instructions for AI agents working with this dotfiles repository.

## Table of Contents

- [Agent Instructions](#agent-instructions)
  - [Table of Contents](#table-of-contents)
  - [Project Context](#project-context)
    - [Branch Strategy](#branch-strategy)
  - [Dependencies](#dependencies)
    - [Required Tools](#required-tools)
    - [Optional Tools](#optional-tools)
    - [Version Requirements](#version-requirements)
    - [Checking Dependencies](#checking-dependencies)
    - [Platform-Specific Installation](#platform-specific-installation)
  - [Documentation Standards](#documentation-standards)
  - [Code Standards](#code-standards)
    - [Shell Script Style](#shell-script-style)
    - [Comments](#comments)
    - [Clean Code Principles](#clean-code-principles)
      - [1. Meaningful Names](#1-meaningful-names)
      - [2. Single Responsibility Principle (SRP)](#2-single-responsibility-principle-srp)
      - [3. Keep It Simple (KISS)](#3-keep-it-simple-kiss)
      - [4. Don't Repeat Yourself (DRY)](#4-dont-repeat-yourself-dry)
      - [5. Functions Should Do One Thing](#5-functions-should-do-one-thing)
      - [6. Avoid Magic Numbers](#6-avoid-magic-numbers)
      - [7. Prefer Readable Code Over Clever Code](#7-prefer-readable-code-over-clever-code)
      - [8. Small Functions](#8-small-functions)
      - [9. Fail Fast](#9-fail-fast)
    - [Error Handling Patterns](#error-handling-patterns)
    - [Bash 3.2 Compatibility](#bash-32-compatibility)
  - [Git Commit Attribution](#git-commit-attribution)
  - [File Organization](#file-organization)
    - [Stow Ignore Files](#stow-ignore-files)
    - [Templates and Secrets](#templates-and-secrets)
    - [Platform-Specific Configs](#platform-specific-configs)
  - [Logging System](#logging-system)
  - [Verbosity System](#verbosity-system)
  - [Helper Functions](#helper-functions)
  - [Validation](#validation)
  - [Update Instructions](#update-instructions)
    - [Triggers for Updates](#triggers-for-updates)
    - [When Adding Instructions](#when-adding-instructions)
    - [Update Frequency](#update-frequency)
  - [Code Quality](#code-quality)
  - [CI/CD](#cicd)
    - [Workflow Structure](#workflow-structure)
    - [CI Performance Optimization](#ci-performance-optimization)
  - [Quick Reference](#quick-reference)
  - [Common Tasks](#common-tasks)
  - [Testing](#testing)
    - [When to Write Tests](#when-to-write-tests)
    - [Test-Driven Bug Fixing Pattern](#test-driven-bug-fixing-pattern)
    - [Running Tests](#running-tests)
    - [Test Categories](#test-categories)
    - [Testing Strategy](#testing-strategy)
    - [Why This Matters](#why-this-matters)
    - [Test Documentation](#test-documentation)
    - [Critical Testing Principles](#critical-testing-principles)
  - [Troubleshooting](#troubleshooting)
    - [Symlink Issues](#symlink-issues)
    - [Installation Problems](#installation-problems)
    - [CI/CD Issues](#cicd-issues)
    - [Rollback Procedures](#rollback-procedures)
  - [Pull Request Workflow](#pull-request-workflow)
  - [GitHub Integration](#github-integration)
    - [When to Use Each Tool](#when-to-use-each-tool)
    - [MCP GitHub Tools](#mcp-github-tools)
    - [GitHub CLI (`gh`)](#github-cli-gh)
    - [Best Practice](#best-practice)

## Project Context

This repository contains dotfiles managed with GNU Stow. Files are organized into packages:

- **system**: System-wide configuration files (`.stow-global-ignore`)
- **git**: Git configuration and global ignore patterns
- **zsh**: Zsh shell configuration (includes Oh My Zsh as submodule)
- **tmux**: Terminal multiplexer configuration
- **gh**: GitHub CLI configuration
- **gnuplot**: GNU Plot configuration
- **bash**: Bash shell configuration
- **fish**: Fish shell configuration

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

### Shell Script Style

Follow these style guidelines based on the [Google Shell Style Guide](https://google.github.io/styleguide/shellguide.html):

**Shebang and Interpreter:**

```bash
#!/usr/bin/env bash
# Or for dotfiles: #!/bin/bash
```

**File Structure:**

1. Shebang line
2. File header comment (brief description)
3. Constants and global variables
4. Helper functions
5. Main logic or `main()` function
6. Call to `main "$@"` (for scripts with multiple functions)

**Formatting:**

- **Indentation**: 2 spaces (no tabs)
- **Line length**: 80 characters preferred, 120 maximum
- **Function braces**: Opening brace on same line as function name

```bash
my_function() {
  local arg="$1"
  # function body
}
```

**Naming Conventions:**

- **Functions**: `lowercase_with_underscores`
- **Local variables**: `lowercase_with_underscores`
- **Global variables**: `lowercase_with_underscores` or `UPPERCASE` if readonly
- **Constants**: `UPPERCASE_WITH_UNDERSCORES`
- **Environment variables**: `UPPERCASE_WITH_UNDERSCORES`

```bash
readonly MAX_RETRIES=3
local retry_count=0
MY_GLOBAL_VAR="value"
```

**Quoting:**

- **Always quote** variables unless you specifically need word splitting
- Quote command substitutions
- Quote strings with spaces or special characters

```bash
# GOOD
local file="$1"
echo "Processing: $file"
result="$(command "$arg")"

# BAD: Unquoted variables
local file=$1
echo Processing: $file
result=$(command $arg)
```

**Command Substitution:**

Use `$()` instead of backticks:

```bash
# GOOD
result="$(command)"
count="$(echo "$list" | wc -l)"

# BAD: Backticks are deprecated
result=`command`
```

**Test and Conditionals:**

- Use `[[ ... ]]` for tests (bash builtin, more powerful)
- Avoid `[ ... ]` (POSIX test, less features)
- Avoid `test` command

```bash
# GOOD
if [[ -f "$file" ]]; then
  echo "File exists"
fi

if [[ "$var" =~ ^[0-9]+$ ]]; then
  echo "Numeric"
fi

# ACCEPTABLE but less powerful
if [ -f "$file" ]; then
  echo "File exists"
fi
```

**Arithmetic:**

Use `(( ))` for arithmetic operations:

```bash
# GOOD
(( count++ ))
(( total = count * 10 ))
if (( count > 10 )); then
  echo "Too many"
fi

# BAD: Using expr
total=$(expr $count \* 10)

# BAD: Using $[]
total=$[ count * 10 ]
```

**Arrays:**

Use bash arrays for lists:

```bash
# GOOD
files=("file1.txt" "file2.txt" "file3.txt")
for file in "${files[@]}"; do
  process "$file"
done

# Access array elements
first="${files[0]}"
all_files="${files[*]}"  # Space-separated string
all_files="${files[@]}"  # Separate arguments
```

**Local Variables:**

Always use `local` for function variables:

```bash
my_function() {
  local input="$1"
  local result
  
  # Separate declaration from command substitution
  result="$(compute "$input")"
  if [[ $? -ne 0 ]]; then
    return 1
  fi
  
  echo "$result"
}
```

**Function Placement:**

Place all functions near the top of the file after constants:

```bash
#!/bin/bash
# Script description

readonly CONSTANT="value"

helper_function() {
  # implementation
}

main_function() {
  # implementation
}

main "$@"
```

**STDOUT vs STDERR:**

Send errors to STDERR:

```bash
echo "Normal output"                    # STDOUT
echo "Error message" >&2                # STDERR
log_error "Failed to process"           # Function sends to STDERR

# Redirect in functions
log_error() {
  echo "[ERROR] $*" >&2
}
```

**Return Value Checking:**

Always check return values:

```bash
# GOOD
if ! command arg1 arg2; then
  log_error "Command failed"
  return 1
fi

# Check specific exit code
command arg1 arg2
if [[ $? -eq 0 ]]; then
  log_success "Success"
fi

# Pipeline status
tar -cf - ./* | (cd "$dir" && tar -xf -)
if [[ ${PIPESTATUS[0]} -ne 0 || ${PIPESTATUS[1]} -ne 0 ]]; then
  log_error "Pipeline failed"
fi
```

**Prefer Builtins:**

Use shell builtins over external commands when possible:

```bash
# GOOD: Builtin parameter expansion
filename="${path##*/}"        # basename
dirname="${path%/*}"          # dirname
extension="${file##*.}"       # file extension
no_ext="${file%.*}"          # remove extension

# ACCEPTABLE but slower: External commands
filename="$(basename "$path")"
dirname="$(dirname "$path")"
```

**Avoid in Scripts:**

- `alias` (use functions instead)
- `eval` (security risk, hard to debug)
- `set -e` (use explicit error checking)

**Main Function Pattern:**

For scripts with multiple functions, use a `main()` function:

```bash
#!/bin/bash
# Script description

readonly VERSION="1.0.0"

process_file() {
  local file="$1"
  # implementation
}

show_help() {
  cat << EOF
Usage: script.sh [options]
Options:
  -h    Show help
EOF
}

main() {
  local file=""
  
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        show_help
        return 0
        ;;
      *)
        file="$1"
        shift
        ;;
    esac
  done
  
  process_file "$file"
}

main "$@"
```

### Comments

**Only add comments when they provide non-obvious information.**

Good comments explain:

- **Why** something is done a certain way
- **Context** that isn't clear from the code
- **Workarounds** for bugs or limitations
- **Performance** considerations
- **Security** implications

Bad comments restate what the code does:

```bash
# BAD: Redundant
# Set variable to value
my_var="value"

# GOOD: Provides context
# Use bash-compatible syntax for macOS default shell (3.2)
my_var="value"
```

**Prefer self-documenting code over comments:**

```bash
# BAD: Needs comment to explain
files=("$@")  # Get all arguments as array

# GOOD: Clear without comment
input_files=("$@")
```

**Remove redundant comments:**

- Section headers that just label code blocks
- Comments that repeat function/variable names
- Obvious operations that need no explanation

**When restructuring removes comment need, restructure.**

### Clean Code Principles

Apply these principles to maintain code quality and readability:

#### 1. Meaningful Names

Use descriptive, specific names that reveal intent:

```bash
# BAD: Unclear, abbreviated
d="$HOME/.dotfiles"
f=("$@")

# GOOD: Clear purpose
dotfiles_dir="$HOME/.dotfiles"
files_to_process=("$@")
```

#### 2. Single Responsibility Principle (SRP)

Each function should have one reason to change:

```bash
# BAD: Function does too much
process_files() {
    validate_input
    backup_files
    transform_files
    log_results
}

# GOOD: Separate responsibilities
validate_input() { ... }
backup_files() { ... }
transform_files() { ... }
log_results() { ... }
```

#### 3. Keep It Simple (KISS)

Favor simple solutions over clever ones:

```bash
# BAD: Overly clever
result=$([[ "$var" =~ ^[0-9]+$ ]] && echo "num" || echo "str")

# GOOD: Clear and simple
if [[ "$var" =~ ^[0-9]+$ ]]; then
    result="num"
else
    result="str"
fi
```

#### 4. Don't Repeat Yourself (DRY)

Extract common patterns into functions:

```bash
# BAD: Repeated logic
log_error "Failed to stow system"
exit 1
# ... later ...
log_error "Failed to stow git"
exit 1

# GOOD: Extracted helper
fail_with_error() {
    log_error "$1"
    exit 1
}

fail_with_error "Failed to stow system"
fail_with_error "Failed to stow git"
```

#### 5. Functions Should Do One Thing

Keep functions focused and cohesive:

```bash
# BAD: Multiple responsibilities
install_package() {
    check_dependencies
    download_files
    verify_checksums
    extract_archive
    configure_settings
    start_service
}

# GOOD: Each function has single purpose
install_package() {
    check_dependencies || return 1
    download_and_verify || return 1
    install_files || return 1
    configure_package || return 1
}
```

#### 6. Avoid Magic Numbers

Use named constants for clarity:

```bash
# BAD: Magic numbers
if [[ ${#backups[@]} -gt 10 ]]; then
    remove_old_backups 5
fi

# GOOD: Named constants
readonly MAX_BACKUPS=10
readonly BACKUPS_TO_KEEP=5

if [[ ${#backups[@]} -gt $MAX_BACKUPS ]]; then
    remove_old_backups "$BACKUPS_TO_KEEP"
fi
```

#### 7. Prefer Readable Code Over Clever Code

Clarity trumps brevity:

```bash
# BAD: Clever but obscure
files=($(find . -type f -exec sh -c 'echo {}' \; | awk '{print $1}' | sort -u))

# GOOD: Clear intent
find_unique_files() {
    find . -type f -print | sort -u
}
files=($(find_unique_files))
```

#### 8. Small Functions

Functions should be short (typically < 20 lines):

- Easy to understand at a glance
- Easy to test
- Easy to name accurately
- Encourage code reuse

#### 9. Fail Fast

Validate inputs early and return immediately:

```bash
# GOOD: Early validation
process_file() {
    local file="$1"
    
    [[ -z "$file" ]] && { log_error "File required"; return 1; }
    [[ ! -f "$file" ]] && { log_error "File not found: $file"; return 1; }
    [[ ! -r "$file" ]] && { log_error "File not readable: $file"; return 1; }
    
    # Main logic here
}
```

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

## Git Commit Attribution

**All commits made by AI agents must use the `--author` flag to distinguish them from user commits.**

AI agents should attribute commits to their tool name rather than the user's personal identity.
This provides clear distinction between manual user contributions and AI-generated changes in the
git history.

**Required pattern for all AI agent commits:**

```bash
git commit --author="<AgentName> <agent@noreply.local>" -m "Commit message"
```

**Agent-specific examples:**

```bash
# Cursor AI
git commit --author="Cursor <cursor@noreply.local>" -m "Add new feature"

# GitHub Copilot
git commit --author="Copilot <copilot@noreply.local>" -m "Add new feature"

# Claude Code
git commit --author="Claude <claude@noreply.local>" -m "Add new feature"

# Other AI tools
git commit --author="<ToolName> <toolname@noreply.local>" -m "Add new feature"
```

**Example workflow:**

```bash
# Make changes to files
echo "new content" > file.txt
git add file.txt

# Commit with AI agent attribution (use your agent's name)
git commit --author="Cursor <cursor@noreply.local>" -m "Add new feature

Detailed description of changes made by the AI agent.
"

# Push changes
git push
```

**Important notes:**

- **Always use the `--author` flag** when committing as an AI agent
- **Identify your tool**: Use your AI agent's actual name (Cursor, Copilot, Claude, etc.)
- **Email format**: Use `<toolname>@noreply.local` (not linked to any GitHub account)
- **User commits**: Do not override author for user's manual commits
- **GitHub operations**: PRs and comments will still show the authenticated GitHub account (platform limitation)
- **Commit message quality**: Follow conventional commit format and provide clear descriptions

**Why this matters:**

- Maintains transparency about AI contributions
- Identifies which AI tool made specific changes
- Allows filtering commits by author in git history
- Distinguishes automated changes from manual user work
- Provides accountability and traceability

**Verification:**

Check commit attribution in git log:

```bash
git log --format="%an <%ae> - %s" -10
```

AI-made commits should show the agent name:

```text
Cursor <cursor@noreply.local> - Document git commit attribution pattern
Claude <claude@noreply.local> - Refactor helper functions
Copilot <copilot@noreply.local> - Add validation checks
Hamish Morgan <hamish.morgan@gmail.com> - Manual user commit
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

**CRITICAL: Always run linting before every commit. Do not commit files with linting errors.**

Before committing changes, verify in this order:

**1. Linting passes (MANDATORY):**

Run linting on all modified files before committing:

```bash
# Markdown files
markdownlint "**/*.md"

# Shell scripts
shellcheck dot bash/.bashrc* bash/.bash_profile zsh/.zshrc* zsh/.zprofile tests/**/*.sh

# Both together
markdownlint "**/*.md" && shellcheck dot bash/.bashrc* bash/.bash_profile zsh/.zshrc* zsh/.zprofile tests/**/*.sh
```

**If linting fails, fix all errors before committing. Zero tolerance for linting errors.**

**2. Smoke tests pass (30 seconds):**

```bash
./tests/smoke-test.sh
```

**3. Full CI passes (2-3 minutes):**

```bash
./tests/run-local-ci.sh
```

**Pre-commit checklist:**

- [ ] Run linting on all modified files
- [ ] Fix all linting errors (zero errors required)
- [ ] Run smoke tests
- [ ] Verify changes work as expected
- [ ] Update AGENTS.md if new patterns added

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
- Configuration files: `.markdownlint.yml`, `.markdownlintignore`, `.shellcheckrc`
- Submodules and external dependencies excluded via `.markdownlintignore`
- Linting runs as prerequisite in CI before validation tests
- **Always run linting after making changes to verify code quality**

## CI/CD

### Workflow Structure

GitHub Actions workflow (`.github/workflows/validate.yml`) uses matrix strategy for efficient testing:

**Job Overview:**

- **lint**: Code quality (shellcheck + markdownlint) - prerequisite for all other jobs
- **smoke-test**: Fast structural validation
- **bats-tests**: All BATS test suites with OS matrix
  - `[ubuntu-latest, macos-latest]` - validates test framework cross-platform
  - Runs unit, integration, regression, and contract tests
- **validate-platform**: Full installation with Bash version matrix
  - Ubuntu + Bash 5.x (modern Linux)
  - Ubuntu + Bash 3.2 (macOS compatibility)
  - macOS + Bash 3.2 (actual macOS)
- **test-summary**: Aggregates results and provides clear pass/fail summary

**Matrix Benefits:**

- Consolidates 4 separate BATS jobs into 1 (saves 6-8 min per run)
- Validates test framework on both Ubuntu and macOS
- Catches platform-specific issues in tests themselves
- DRY approach reduces duplication

### CI Performance Optimization

Key learnings from CI optimization work (Issue #42, PR #58, Issue #22):

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

Phase 1 optimizations (Issue #42, PR #58) reduced CI time from 8-12 minutes to ~1 minute (92% improvement):

- Linting: 90s → 15s (83% faster)
- Smoke: 30s → 6s (80% faster)
- Ubuntu: 120s → 28s (77% faster)
- Bash 3.2: 120s → 32s (73% faster, cache miss)
- macOS: 180s → 26s (86% faster)

Phase 2 optimizations (Issue #22) consolidated BATS tests:

- **Before**: 4 separate BATS jobs × 2 min setup = 8 min overhead
- **After**: 1 BATS job with OS matrix = 2 min overhead
- **Savings**: 6 min per CI run (~25% additional improvement)
- **Bonus**: BATS tests now validate on macOS (was Ubuntu-only)

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
| Lint Bash | `shellcheck dot bash/.bashrc* bash/.bash_profile zsh/.zshrc* zsh/.zprofile tests/**/*.sh` | 5s |
| Monitor CI | `gh pr checks <PR>` | instant |
| View CI logs | `gh run view --log-failed` | instant |

## Common Tasks

- Installation: `./dot install` (add `-v` or `-vv` for more detail)
- Update: `./dot update` (add `-v` or `-vv` for more detail)
- Status check: `./dot status`
- Health check: `./dot health` (add `-v` for detailed output)
- Linting: `markdownlint "**/*.md"` and `shellcheck dot bash/.bashrc* bash/.bash_profile zsh/.zshrc* zsh/.zprofile`
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

### When to Write Tests

**Always write tests for:**

1. **Bug Fixes (Regression Tests)** - Write failing test BEFORE implementing fix
   - Create test that reproduces the bug
   - Verify test fails
   - Implement fix
   - Verify test passes
   - Prevents bug from returning
   - Example: `tests/regression/test_issue_66.bats`

2. **New Functions (Unit Tests)** - Write tests for critical helper functions
   - Test edge cases and error conditions
   - Verify return values and side effects
   - Example: `tests/unit/test_backup_functions.bats`

3. **New Commands (Integration Tests)** - Test full command workflows
   - Verify exit codes
   - Validate output format
   - Example: `tests/integration/test_health.bats`

4. **Output Changes (Contract Tests)** - Update when changing user-facing output
   - Ensure output format stability
   - Verify required sections present
   - Example: `tests/contract/test_health_output.bats`

### Test-Driven Bug Fixing Pattern

**Critical:** Write failing regression test before fixing bugs.

```bash
# 1. Create regression test that demonstrates the bug
cat > tests/regression/test_issue_XX.bats << 'EOF'
@test "Issue #XX: describe the bug" {
    # Setup to reproduce bug
    create_mock_backups 15 1
    
    run ./dot health
    
    # This FAILS on the bug (what we want)
    assert_output_not_contains "using 0MB"
}
EOF

# 2. Run test - should FAIL
bats tests/regression/test_issue_XX.bats
# Expected: FAIL (bug present)

# 3. Fix the bug in code
# (make your changes)

# 4. Run test again - should PASS
bats tests/regression/test_issue_XX.bats
# Expected: PASS (bug fixed)

# 5. Commit both test and fix together
git add tests/regression/test_issue_XX.bats
git add dot  # or whatever file was fixed
git commit -m "Fix Issue #XX with regression test"
```

### Running Tests

**Before committing:**

```bash
# Regression tests (fast, critical)
bats tests/regression/

# Smoke tests (30 seconds)
./tests/smoke-test.sh
```

**During development:**

```bash
# Run all BATS tests
./tests/run-bats.sh

# Or specific suites
bats tests/unit/          # Function-level tests
bats tests/integration/   # Command-level tests
bats tests/contract/      # Output validation
```

**Before pushing:**

```bash
# Full cross-platform tests (2-3 minutes, requires Docker or Podman)
./tests/run-local-ci.sh
```

### Test Categories

1. **Regression Tests** - One per bug, written BEFORE fix
2. **Unit Tests** - Test functions in isolation
3. **Integration Tests** - Test complete commands
4. **Contract Tests** - Validate output format
5. **Smoke Tests** - Fast structural validation

### Testing Strategy

- **BATS tests**: Automated unit, integration, and regression testing
- **Regression tests**: Write BEFORE fixing bug (TDD pattern)
- **Smoke tests**: Fast validation of basic functionality and structure
- **Container tests**: Full installation on Ubuntu and Alpine (BSD-like)
- **GitHub Actions**: Final validation on real Ubuntu and macOS runners

### Why This Matters

**BATS tests catch logic bugs:**

- Variable name typos (Issue #66: `$backup_size` vs `$backup_size_kb`)
- Calculation errors
- Output format changes
- Function contract violations

**Cross-platform tests catch compatibility issues:**

1. Alpine tests (BusyBox = BSD-like coreutils)
2. GitHub Actions macOS runner (actual macOS)

Always run tests before committing. Regression tests are mandatory for bug fixes.

### Test Documentation

See DEVELOPMENT.md Testing section for comprehensive testing framework documentation.

### Critical Testing Principles

**DO NOT create "acceptable failure" tests:**

```bash
# ❌ BAD: Allowing either success or failure
run ./dot health
[[ "$status" -eq 0 || "$status" -eq 1 ]]  # This is an anti-pattern!

# ✅ GOOD: Test specific behavior
# If testing backup display, test the function directly
source_dot_script
run get_backup_stats
assert_success
assert_output --regexp "[0-9]+ [0-9]+"

# ✅ GOOD: Or ensure proper test environment
./dot install > /dev/null 2>&1  # Set up environment
run ./dot health
# Now health should have deterministic result
```

**Tests must have clear expectations:**

- If a command should succeed, assert `assert_success`
- If a command should fail, assert `assert_failure` (exit code 1)  
- Never use `[[ "$status" -eq 0 || "$status" -eq 1 ]]` as a cop-out
- If environment affects results, mock/set up the environment properly

**Test functions in isolation when possible:**

- Integration tests test full commands (slower, environmental dependencies)

- Unit tests test functions directly (faster, more reliable)
- Prefer unit tests for specific functionality
- Use integration tests for end-to-end workflows
Before (anti-pattern):

```bash
@test "health shows backups" {

    run ./dot health
    # May fail in test env - BAD!
    [[ "$status" -eq 0 || "$status" -eq 1 ]]

    assert_output --partial "15 backups"
}
```

After (correct):

```bash
@test "get_backup_stats returns correct values" {
    create_mock_backups 15 1
    source_dot_script
    run get_backup_stats
    assert_success  # Function must succeed
    count=$(echo "$output" | awk '{print $1}')
    assert_equal "15" "$count"
}
```

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
for pkg in system git zsh tmux gh gnuplot bash fish; do
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
