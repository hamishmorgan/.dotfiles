# Agent Instructions

Instructions for AI agents working with this dotfiles repository.

## Table of Contents

- [Agent Instructions](#agent-instructions)
  - [Table of Contents](#table-of-contents)
  - [Workflows](#workflows)
  - [Project Context](#project-context)
    - [Machine-Specific Configuration Strategy](#machine-specific-configuration-strategy)
  - [Dependencies](#dependencies)
    - [Required Tools](#required-tools)
    - [Optional Tools](#optional-tools)
    - [Version Requirements](#version-requirements)
    - [Checking Dependencies](#checking-dependencies)
    - [Platform-Specific Installation](#platform-specific-installation)
  - [Documentation Standards](#documentation-standards)
  - [Code Standards](#code-standards)
    - [Environment Variables](#environment-variables)
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
    - [Argument Parsing Patterns](#argument-parsing-patterns)
    - [Bash 3.2 Compatibility](#bash-32-compatibility)
  - [Git Commit Attribution](#git-commit-attribution)
  - [File Organization](#file-organization)
    - [Component-Specific Documentation](#component-specific-documentation)
    - [Stow Ignore Files](#stow-ignore-files)
    - [Configuration Files](#configuration-files)
    - [Optional Enhancement Configs](#optional-enhancement-configs)
    - [Platform-Specific Configs](#platform-specific-configs)
  - [Logging System](#logging-system)
  - [Verbosity System](#verbosity-system)
  - [Helper Functions](#helper-functions)
  - [Code Quality](#code-quality)
  - [CI/CD](#cicd)
  - [Quick Reference](#quick-reference)
    - [User Commands](#user-commands)
    - [Development Commands](#development-commands)
    - [GitHub Commands](#github-commands)
  - [Common Tasks](#common-tasks)
    - [User Workflow](#user-workflow)
    - [Development Workflow](#development-workflow)
  - [Testing](#testing)
    - [Test Categories](#test-categories)
    - [Testing Documentation](#testing-documentation)
  - [GitHub Integration](#github-integration)

## Workflows

High-level procedural workflows are maintained in `.cursor/rules/` for automatic loading by Cursor IDE:

- **Pull Request Workflow**: `.cursor/rules/pull-request-workflow.mdc` - Complete PR process from creation to merge
- **Testing Workflow**: `.cursor/rules/testing-workflow.mdc` - Test-driven development and critical testing principles
- **Validation Workflow**: `.cursor/rules/validation-workflow.mdc` - Pre-commit validation checklist
- **Troubleshooting**: `.cursor/rules/troubleshooting-workflow.mdc` - Common issues and resolution procedures
- **Update Instructions**: `.cursor/rules/update-instructions-workflow.mdc` - How to maintain AGENTS.md and workflow files

These files contain step-by-step procedures. All reference material (standards, patterns, architecture) remains in this file.

## Project Context

This repository contains dotfiles managed with GNU Stow. Files are organized into packages under the `packages/` directory:

- **system**: System-wide configuration files (`.stow-global-ignore`)
- **git**: Git configuration and global ignore patterns
- **zsh**: Zsh shell configuration (includes Oh My Zsh as submodule)
- **tmux**: Terminal multiplexer configuration
- **gh**: GitHub CLI configuration
- **gnuplot**: GNU Plot configuration
- **bash**: Bash shell configuration
- **fish**: Fish shell configuration
- **wezterm**: WezTerm terminal emulator configuration
- **bat**: Bat syntax highlighter configuration
- **rust**: Rust toolchain configuration

Template-based secrets management separates public templates from private secret configurations.
Packages are discovered automatically via manifests and can be stowed in any order.

**Repository Structure:**

- `packages/`: Stowable configuration packages
- `dev/`: Development tools (linting, testing, CI)
- `tests/`: Test infrastructure (BATS, smoke tests, CI)
- `dot`: Main user-facing script
- `tmp/`: Temporary files and proposals (git-ignored, not committed)

**Documentation Structure:**

- **README.md**: User-facing documentation (installation, usage, features)
- **DEVELOPMENT.md**: Developer documentation (setup, workflow, testing, CI, architecture)
- **AGENTS.md**: AI agent instructions (this file - technical implementation guidance)
- **tests/README.md**: Testing framework documentation

### Machine-Specific Configuration Strategy

Machine-specific configuration uses `.local` files for per-machine customization without
branch complexity.

**Single branch approach:**

- **main branch**: All shared configuration (works on all machines)
- **`.local` files**: Machine-specific overrides (git-ignored)

**Configuration layers:**

```bash
~/.bashrc               # Symlinked from repo, contains base config + conditional integrations
~/.bashrc.local         # Git-ignored, machine-specific customizations
~/.gitconfig            # Generated from template + secret
~/.gitconfig.local      # Git-ignored, machine-specific git settings
```

**Why .local files instead of branches:**

- Single branch eliminates rebasing complexity
- Machine-specific configs stay separate from shared configs
- No git conflicts from auto-appending tools
- Works across unlimited machines without branch proliferation
- Simpler mental model (base + machine overlay)
- Standard pattern used by many dotfiles implementations

**Handling Auto-Appending Tools:**

Development tools (Shopify's `dev`, `tec agent`, etc.) automatically append initialization
code to shell configs. The dotfiles handle this by:

1. **Pre-including integrations** with conditional checks (safe on all machines)
2. **Accepting duplication** when tools re-append (creates git noise but manageable)
3. **Git workflow** using `git add -p` to skip duplicate lines when committing

**Managing git noise from auto-appends:**

```bash
# Interactive staging - skip duplicates
git add -p packages/bash/.bashrc

# Or reset before committing
git checkout -- packages/bash/.bashrc packages/zsh/.zshrc
```

Runtime profiles and branch-based strategies add unnecessary complexity for single-user
dotfiles when tools forcibly modify config files daily.

**Key learnings about auto-appending tools:**

Based on investigation of Shopify's dev tools (`/opt/dev/dev.sh`, `tec agent`):

- **No prevention mechanism**: Tools hardcode append to `~/.bashrc`, `~/.zshrc`, etc.
- **No environment variables**: Cannot redirect where they append
- **No sentinel markers**: Tools don't check for existing config before appending
- **No configuration options**: Cannot disable auto-append behavior
- **Daily+ frequency**: Some tools re-append after updates (varies by tool)
- **Idempotent loading**: Tools use guards (e.g., `USING_DEV` env var) to prevent double-loading

Design decision: Accept manageable git noise

Given constraints (daily+ re-appends, frequent commits from work machine), evaluated:

- Chezmoi migration (1-2 weeks effort, bidirectional sync, templating)
- XDG launcher pattern (breaks stow model for shell configs)
- Git assume-unchanged/skip-worktree (hidden state, easy to forget)
- Two-repository overlay (complexity, doesn't solve appends)

Chosen: Pre-add integrations + .local files + accept git noise

Rationale:

- Keeps stow (simple, proven)
- Single branch (no rebasing)
- Tools duplicate existing code (easy to identify)
- Use `git add -p` to skip duplicates when staging
- Small price for avoiding complex migrations

Alternative: Migrate to chezmoi later if git noise becomes unmanageable.

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
- **Follow `.editorconfig` rules** (`packages/system/.editorconfig`):
  - Remove trailing whitespace (except in Markdown)
  - Use LF line endings
  - Insert final newline
  - Use 2-space indentation for shell scripts

### Environment Variables

**Naming Convention:**

- External (environment): `DOTFILES_<INTERNAL_NAME>`
- Internal (readonly): `<DESCRIPTIVE_NAME>`
- Pattern: External = `DOTFILES_` + Internal (exact match, no transformation)

**Examples:**

```bash
# External → Internal (just add/remove DOTFILES_ prefix)
DOTFILES_GIT_TIMEOUT → GIT_TIMEOUT
DOTFILES_MAX_BACKUPS_TO_KEEP → MAX_BACKUPS_TO_KEEP
DOTFILES_SECRET_FILE_MODE → SECRET_FILE_MODE
```

**Implementation Pattern:**

```bash
# Configuration section with inline comments
readonly INTERNAL_NAME="${DOTFILES_INTERNAL_NAME:-default_value}"    # Purpose

# Usage in code
if portable_timeout "$GIT_TIMEOUT" git submodule update; then
    log_success "Submodules updated"
fi
```

**When to Add Environment Variables:**

- User-configurable values (timeouts, limits, display counts)
- Security settings (file permissions)
- Path customization (backup locations)

**When NOT to Add:**

- Universal constants (86400 seconds/day, 1024 KB/MB)
  - Use `readonly CONSTANT=value` instead
- Internal-only values not useful to users
- Values that should never change

**Documentation Required:**

When adding environment variables:

1. **README.md**: Add to Configuration section with examples
2. **AGENTS.md**: Update this section if adding new patterns
3. **Inline comments**: Document purpose in configuration section

**Current Environment Variables:**

Display & Retention:

- `DOTFILES_MAX_BACKUPS_TO_DISPLAY` (5) - Status output
- `DOTFILES_MAX_BACKUPS_TO_KEEP` (10) - Retention policy
- `DOTFILES_RESTORE_DISPLAY_LIMIT` (20) - Restore preview

Timeouts:

- `DOTFILES_GIT_TIMEOUT` (60) - Git operations
- `DOTFILES_CURL_TIMEOUT` (30) - Curl downloads

Security:

- `DOTFILES_SECRET_FILE_MODE` (600) - Secret file permissions

Output:

- `DOTFILES_OUTPUT_PREFIX` (│) - Indentation character

Backup Paths:

- `DOTFILES_BACKUP_DIR_PREFIX` (backups/dotfiles-backup) - Backup directory prefix
- `DOTFILES_RESTORE_SAFETY_PREFIX` (backups/dotfiles-pre-restore) - Restore safety prefix

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

### Argument Parsing Patterns

**Commands with Arguments:**

When implementing commands that accept arguments (like `enable PACKAGE`, `restore BACKUP_ID`),
use the `COMMAND_ARGS` array pattern:

```bash
# In parse_arguments()
parse_arguments() {
    COMMAND=""
    VERBOSITY=0
    COMMAND_ARGS=()
    
    # ... parse flags and options ...
    
    # When command is found, collect remaining args
    case $1 in
        enable|disable|restore)
            COMMAND="$1"
            shift
            # Collect all remaining arguments
            while [[ $# -gt 0 ]]; do
                COMMAND_ARGS+=("$1")
                shift
            done
            ;;
    esac
}

# In main()
main() {
    parse_arguments "$@"
    
    case $COMMAND in
        enable)
            # Pass collected arguments to command
            cmd_enable "${COMMAND_ARGS[@]}"
            ;;
    esac
}
```

**Why this pattern:**

- `parse_arguments` consumes all arguments during parsing
- Trying to `shift` in `main()` after parsing leaves `$@` empty
- `COMMAND_ARGS` array preserves arguments for commands that need them
- Bash 3.2 compatible (uses regular arrays, not associative)

**Related:** Issue #90, PR #111 - Discovered during `bat` package implementation

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

- **User tool**: `dot` script in root
- **Utilities**: `bin/` directory (standalone scripts like `disk-cleanup`)
- **Development tools**: `dev/` directory (atomic and composite workflow commands)
- **Package files**: `packages/` directory (system/, git/, zsh/, tmux/, gh/, gnuplot/, bash/, fish/, bat/, cursor/)
- **Test suites**: `tests/` directory (BATS tests, test helpers, CI infrastructure)
- **Configuration**: Dot-prefixed names (`.gitconfig`, `.zshrc`, etc.)
- **Temporary files**: `tmp/` directory (git-ignored, for proposals and temporary docs)
- `.gitignore` is project-specific, not managed by stow

**Important Path Variables:**

- `DOTFILES_DIR`: Repository root (e.g., `$HOME/.dotfiles`)
- `PACKAGES_DIR`: Package directory (`$DOTFILES_DIR/packages`)
- Always use `$PACKAGES_DIR` when referencing package directories in code
- Example: `$PACKAGES_DIR/bat` not `$DOTFILES_DIR/bat`

### Component-Specific Documentation

Component-specific documentation has been moved to co-located files for better discoverability and contextual loading:

- **Cursor IDE Configuration**: `packages/cursor/README.md`
- **Disk Cleanup Utility**: `bin/README.md`
- **Development Directory**: `dev/README.md`
- **CI/CD**: `.cursor/rules/ci-cd.mdc` (loads when editing `.github/workflows/**`)
- **GitHub Integration**: `.cursor/rules/github-integration.mdc` (on-demand, referenced from PR workflow)
- **Testing Strategy**: `tests/README.md` (see Testing section below for taxonomy)

### Individual File Listing (Best Practice)

**Default approach:** List individual files in `get_package_files()`, not directory names.

**Why this is the default:**

1. **Safety**: Prevents `backup_existing()` from removing entire directories with `rm -rf`
2. **Precision**: Only manages files you explicitly specify
3. **Coexistence**: Allows dotfiles-managed and user-generated files in same directory
4. **Predictability**: Clear what's managed vs. what's not

**Implementation:**

```bash
get_package_files() {
    case "$package" in
        # ✅ GOOD: Individual files listed
        gh)   echo ".config/gh/config.yml,.config/gh/hosts.yml" ;;
        bat)  echo ".config/bat/config" ;;
        rust) echo ".cargo/config.toml,.rustfmt.toml" ;;
        
        # ⚠️ EXCEPTIONS: Directories (only when safe)
        zsh)  echo ".zshrc,.zprofile,.oh-my-zsh" ;;  # .oh-my-zsh is submodule
    esac
}
```

**When directories are acceptable:**

- Submodules (like `.oh-my-zsh`) - fully managed by git
- Tool-specific directories where dotfiles owns ALL content
- Directories that won't have user data mixed in

**Critical for mixed config+data directories:**

When a directory contains both dotfiles-managed configs AND user/runtime data,
individual file listing is **required** to prevent data loss.

**Example: `.cargo/` directory**

Contains both:

- **Dotfiles-managed**: `.cargo/config.toml`, `~/.rustfmt.toml` (version-controlled)
- **User data**: `.cargo/bin/`, `.cargo/credentials.toml`, `.cargo/env`, `.cargo/registry/` (machine-specific)

Listing `.cargo` as a directory causes `backup_existing()` to `rm -rf ~/.cargo`, deleting all user data.

### Mixed Config+Data Directories (`packages/rust/` and similar)

**Packages updated to use individual file listing (PR #123):**

- `gh`: `.config/gh/config.yml,.config/gh/hosts.yml` (was `.config/gh`)
- `fish`: Individual config files + functions directory (was `.config/fish`)
- `wezterm`: `.wezterm.lua` (was `.config/wezterm`)
- `bat`: `.config/bat/config` (was `.config/bat`)
- `rust`: Individual `.cargo/` files (designed this way from start)

**Historical context:**

Previously discovered when rust package deleted `~/.cargo/bin/`, credentials, and caches.
Listing `.cargo` as a directory caused `backup_existing()` to `rm -rf ~/.cargo`.
Individual file listing prevents this by only backing up and removing specific files.

### Stow Ignore Files

- **`system/.stow-global-ignore`**: Symlinked to `~/.stow-global-ignore`, contains universal patterns
  for all stow operations
- **Package `.stow-local-ignore`**: In each package directory (e.g., `git/.stow-local-ignore`),
  contains package-specific ignore patterns
- Template/secret/example files are ignored via `.stow-local-ignore` in each package

### Configuration Files

- Configuration files (`.gitconfig`, `config.yml`, etc.) contain shared defaults
- Example files (`.example` files) show format for machine-specific configs
- Machine-specific configs (`.local` files) override defaults per-machine
- **`.local` files are NOT stowed** - ignored via package `.stow-local-ignore` files
- **`.local` files are secured** - automatically set to mode 600 during installation

### Optional Enhancement Configs

Some configurations support optional tools through stow + manual activation:

**Git Delta** (`.gitconfig.delta`):

- Enhanced diff viewer configuration
- **Stowed** like other config files (symlinked to `~/.gitconfig.delta`)
- User manually activates by adding `[include] path = ~/.gitconfig.delta` to `~/.gitconfig.local`
- No automatic detection or modification of user files
- Follows existing pattern: install tool → configure in `.local` file

**Implementation Pattern:**

1. Create enhancement config file (e.g., `.gitconfig.delta`)
2. Let stow handle it (symlink like other configs)
3. Document activation in README (add include to `.gitconfig.local`)
4. User controls when/if to enable it

**Why this approach:**

- Respects user ownership of `.local` files (installer never modifies them)
- Simple and transparent (no hidden magic)
- Consistent with existing optional tools (eza, etc.)
- No need for conditional logic in installation pipeline

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

## Code Quality

- All Markdown files must pass markdownlint validation
- All Bash scripts must pass shellcheck validation
- Configuration files: `.markdownlint.yml`, `.markdownlintignore`, `.shellcheckrc`
- Submodules and external dependencies excluded via `.markdownlintignore`
- Linting runs as prerequisite in CI before validation tests
- **Always run linting after making changes to verify code quality**

## CI/CD

See `.cursor/rules/ci-cd.mdc` for CI/CD workflow structure and performance optimization patterns.
This documentation loads automatically when editing `.github/workflows/**` files.

## Quick Reference

### User Commands

| Task | Command | Time |
|------|---------|------|
| Install dotfiles | `./dot install` | 1-2m |
| Update dotfiles | `./dot update` | 1-2m |
| Check health | `./dot health` | instant |
| Check status | `./dot status` | instant |

### Development Commands

| Task | Command | Time |
|------|---------|------|
| Complete validation | `./dev/check` | 3-4m |
| All linting | `./dev/lint` | 10s |
| All tests | `./dev/test` | 1m |
| Lint Markdown | `./dev/lint-markdown` | 5s |
| Lint Shell | `./dev/lint-shell` | 5s |
| Smoke tests | `./dev/smoke` | 30s |
| BATS tests | `./dev/bats` | 30s |
| Local CI | `./dev/ci` | 2-3m |
| Setup dev env | `./dev/setup` | varies |
| Show all commands | `./dev/help` | instant |

### GitHub Commands

| Task | Command | Time |
|------|---------|------|
| Monitor CI | `gh pr checks <PR>` | instant |
| View CI logs | `gh run view --log-failed` | instant |

## Common Tasks

### User Workflow

- Installation: `./dot install` (add `-v` or `-vv` for more detail)
- Update: `./dot update` (add `-v` or `-vv` for more detail)
- Status check: `./dot status`
- Health check: `./dot health` (add `-v` for detailed output)
- Package management: `stow --verbose --restow --dir=. --target=$HOME package_name`
- Backup location: `backups/dotfiles-backup-*` (timestamped directories)

**Verbosity Examples:**

```bash
./dot install          # Clean summary
./dot install -v       # Show packages
./dot install -vv      # Show all files
./dot health           # Table format
./dot health -v        # Detailed checks
```

### Development Workflow

- Complete validation: `./dev/check` (lint + test + ci)
- Before commit: `./dev/lint && ./dev/test` (fast, ~1m)
- Fast iteration: `./dev/lint-shell` or `./dev/smoke` (seconds)
- Specific linting: `./dev/lint-markdown` or `./dev/lint-shell`
- Specific testing: `./dev/smoke` or `./dev/bats`
- Setup environment: `./dev/setup`
- Show all commands: `./dev/help`

**Development Examples:**

```bash
# First time setup
./dev/setup

# Fast iteration on shell code
./dev/lint-shell        # ~5s

# Before commit (recommended)
./dev/lint && ./dev/test   # ~1m

# Before push (comprehensive)
./dev/check             # ~3-4m

# Test specific platform
./dev/ci alpine         # BSD-like coreutils
```

## Testing

See `.cursor/rules/testing-workflow.mdc` for procedural testing workflow (when to write tests, TDD pattern,
critical principles, running tests).

### Test Categories

1. **Regression Tests** - One per bug, written BEFORE fix
2. **Unit Tests** - Test functions in isolation
3. **Integration Tests** - Test complete commands
4. **Contract Tests** - Validate output format
5. **Smoke Tests** - Fast structural validation

### Testing Documentation

- **Procedural workflow**: See `.cursor/rules/testing-workflow.mdc` for when to write tests, TDD pattern, critical principles
- **Testing strategy**: See `tests/README.md` for comprehensive testing strategy, test types, and framework documentation
- **Comprehensive framework**: See DEVELOPMENT.md Testing section for detailed testing framework documentation

## GitHub Integration

See `.cursor/rules/github-integration.mdc` for GitHub integration patterns, MCP tools vs `gh` CLI usage, and best practices.
This documentation is available on-demand and referenced from the pull request workflow.
