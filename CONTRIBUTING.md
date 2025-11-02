# Contributing to .dotfiles

Thank you for your interest in contributing. This guide covers the contribution workflow, development
practices, and project standards.

## Quick Start

```bash
# Fork repository on GitHub

# Clone your fork
git clone git@github.com:YOUR_USERNAME/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Add upstream remote
git remote add upstream git@github.com:hamishmorgan/.dotfiles.git

# Setup development environment
./dev/setup
```

## Before You Start

- Read [DEVELOPMENT.md](DEVELOPMENT.md) for code standards and architecture
- Check [existing issues](https://github.com/hamishmorgan/.dotfiles/issues) for similar work
- Review [AGENTS.md](AGENTS.md) for AI agent patterns and anti-patterns

## Development Workflow

### 1. Create Feature Branch

```bash
git checkout main
git pull upstream main
git checkout -b feature/your-feature-name
```

### 2. Make Changes

Follow these principles:

- **One logical change per commit**
- **Test before committing**
- **Follow code standards** (see below)
- **Update documentation** for user-facing changes

### 3. Test Locally

```bash
# Fast iteration (recommended during development)
./dev/lint-shell      # ~5s - Shellcheck only
./dev/smoke           # ~30s - Basic validation

# Before commit (comprehensive)
./dev/lint && ./dev/test  # ~1m - All linting + tests

# Before push (complete validation)
./dev/check           # ~3-4m - Lint + test + local CI
```

### 4. Commit Changes

Use [conventional commits](https://www.conventionalcommits.org/) format:

```bash
git add <files>
git commit -m "type(scope): description

Detailed explanation of changes.

- Specific change 1
- Specific change 2"
```

**Types:**

- `feat` - New feature
- `fix` - Bug fix
- `docs` - Documentation
- `style` - Formatting
- `refactor` - Code restructuring
- `perf` - Performance
- `test` - Tests
- `chore` - Maintenance

**Examples:**

```bash
git commit -m "feat(packages): add rust toolchain configuration"
git commit -m "fix(health): correct backup size calculation"
git commit -m "docs(readme): document restore command"
```

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name

# Create PR via GitHub CLI
gh pr create --title "feat: your feature" --body "Description"
```

### 6. Address Review Feedback

- Wait for CI to pass
- Wait for code review
- Address all feedback
- Push updates incrementally

## Adding a New Package

### 1. Create Package Directory

```bash
mkdir -p packages/PACKAGE_NAME
```

### 2. Create Manifest

Create `packages/PACKAGE_NAME/manifest.toml`:

```toml
files = [".config/tool/config.yml", ".config/tool/settings.json"]

name = "Package Display Name"
description = "Brief description"
method = "stow"        # or "copy-sync" for tools that don't support symlinks
target = "~"

[validation]
"*.yml" = { command = "tool", args = ["validate", "file"] }

[update]
command = "dev/update-script"
args = ["file"]
```

**Required fields:**

- `files` - Array of files to manage
- `name` - Display name
- `description` - Brief description

**Optional fields:**

- `method` - Installation method (default: "stow")
- `target` - Target directory (default: "~")
- `validation` - Syntax validation commands
- `update` - Package-specific update commands

### 3. Add Configuration Files

```bash
# Copy configuration files to package directory
cp ~/.config/tool/config.yml packages/PACKAGE_NAME/.config/tool/

# Create .stow-local-ignore for files to exclude
echo ".local" > packages/PACKAGE_NAME/.stow-local-ignore
echo "*.example" >> packages/PACKAGE_NAME/.stow-local-ignore
```

### 4. Create Package README

Create `packages/PACKAGE_NAME/README.md`:

```markdown
# Package Name

Brief description of what this package configures.

## Installation

\`\`\`bash
./dot enable PACKAGE_NAME
\`\`\`

## What's Included

- Configuration file 1
- Configuration file 2

## Configuration

How to customize for individual machines.

## Usage

How to use the configured tool.
```

### 5. Test the Package

```bash
# Enable package
./dot enable PACKAGE_NAME

# Check health
./dot health -v

# Verify symlinks
ls -la ~/.config/tool/

# Test tool functionality
tool --version
```

### 6. Update Documentation

Add package to README.md package list (line 19):

```markdown
- Packages: git, zsh, tmux, gh, gnuplot, bash, fish, wezterm, bat, rust, PACKAGE_NAME
```

### 7. Submit PR

```bash
git add packages/PACKAGE_NAME
git commit -m "feat(packages): add PACKAGE_NAME configuration"
git push origin feature/add-PACKAGE_NAME
gh pr create
```

## Fixing Bugs

### Test-Driven Bug Fix Pattern (REQUIRED)

**Always write a failing test before fixing bugs:**

1. **Create regression test** that reproduces the bug
2. **Verify test fails** (bug is present)
3. **Fix the bug** in code
4. **Verify test passes** (bug is fixed)
5. **Commit test and fix together**

**Example:**

```bash
# 1. Create test file
cat > tests/regression/test_issue_XX.bats << 'EOF'
@test "Issue #XX: describe bug behavior" {
    # Setup that triggers bug
    create_mock_backups 15 1
    
    run ./dot health
    
    # Assertion that fails on the bug
    assert_output_not_contains "using 0MB"
}
EOF

# 2. Run test - should FAIL
bats tests/regression/test_issue_XX.bats
# Output: ✗ Issue #XX: describe bug behavior

# 3. Fix the bug in code
# (edit dot script or relevant file)

# 4. Run test again - should PASS
bats tests/regression/test_issue_XX.bats
# Output: ✓ Issue #XX: describe bug behavior

# 5. Commit both
git add tests/regression/test_issue_XX.bats dot
git commit -m "fix: Issue #XX - describe bug

Regression test added to prevent recurrence."
```

See [.cursor/rules/testing-workflow.mdc](.cursor/rules/testing-workflow.mdc) for detailed testing guidelines.

## Code Standards

### Bash Style

- **Bash 3.2 compatible** (macOS default)
- **Long-form arguments** for stow: `--verbose`, `--restow`
- **Short-form arguments** for coreutils: `-p`, `-r` (BSD compatibility)
- **Explicit error handling** (no `set -e`)
- **2-space indentation**
- **Descriptive variable names**

### What to Avoid

❌ Associative arrays (Bash 4.0+)
❌ `mapfile` command (Bash 4.0+)
❌ `&>>` redirect (Bash 4.0+)
❌ `set -e` (use explicit checks)

✅ Functions for key-value storage
✅ `while read` loops
✅ Separate redirects (`> file 2>&1`)
✅ Explicit `if ! command; then` checks

### Documentation Style

- Formal, minimal, reserved tone
- Technically precise language
- No marketing language or exclamations
- Focus on essential information

## Testing

### Test Categories

1. **Regression** - One test per bug (prevents recurrence)
2. **Unit** - Test functions in isolation
3. **Integration** - Test complete commands
4. **Contract** - Validate output format
5. **Smoke** - Fast structural validation

### Running Tests

```bash
# Individual test suites
bats tests/regression/      # Bug prevention
bats tests/unit/            # Function tests
bats tests/integration/     # Command tests
bats tests/contract/        # Output validation

# All BATS tests
./dev/bats

# Smoke tests
./dev/smoke

# Local CI (cross-platform)
./dev/ci
```

See [tests/README.md](tests/README.md) for comprehensive testing documentation.

## Pull Request Process

### Before Creating PR

1. ✅ Run `./dev/lint` - All linting must pass
2. ✅ Run `./dev/test` - All tests must pass
3. ✅ Run `./dev/ci` - Local CI must pass
4. ✅ Update documentation for user-facing changes
5. ✅ Add regression test for bug fixes
6. ✅ Follow conventional commit format

### PR Template

The PR template includes an automatic checklist. Ensure all items are checked:

- [ ] Code follows style guidelines
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Linting passes
- [ ] Local CI passes
- [ ] Regression test included (for bug fixes)

### Review Process

1. **Automated checks** - CI must pass
2. **AI review** - Copilot provides feedback
3. **Human review** - Maintainer reviews code
4. **Iterate** - Address feedback, update PR
5. **Merge** - After approval from all reviewers

See [.cursor/rules/pull-request-workflow.mdc](.cursor/rules/pull-request-workflow.mdc) for detailed PR workflow.

## Documentation

### When to Update Documentation

- **README.md** - User-facing changes (new commands, features, configuration)
- **DEVELOPMENT.md** - Developer changes (new tests, CI, architecture)
- **COMMANDS.md** - New or modified commands
- **AGENTS.md** - New patterns, lessons learned, anti-patterns
- **Package README** - Package-specific changes

### Documentation Standards

- Keep README.md user-focused (installation, usage, features)
- Keep DEVELOPMENT.md developer-focused (workflow, architecture, testing)
- Keep COMMANDS.md as comprehensive reference
- Add examples for all new features
- Update cross-references between docs

## Release Process

Maintainers only:

1. Update version in `dot` script
2. Update CHANGELOG.md
3. Create git tag
4. Push to GitHub

```bash
# Update version
vim dot  # Change DOT_VERSION

# Commit
git add dot
git commit -m "chore: bump version to 1.2.0"

# Tag
git tag -a v1.2.0 -m "Release v1.2.0"

# Push
git push origin main --tags
```

## Getting Help

- **Questions** - Open an issue with `question` label
- **Bugs** - Open an issue with `bug` label  
- **Features** - Open an issue with `enhancement` label
- **Discussion** - Use GitHub Discussions

## Code of Conduct

- Be respectful and constructive
- Focus on the code, not the person
- Assume positive intent
- Help others learn and grow

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

## Additional Resources

- [DEVELOPMENT.md](DEVELOPMENT.md) - Developer documentation
- [COMMANDS.md](COMMANDS.md) - Command reference
- [AGENTS.md](AGENTS.md) - AI agent instructions
- [tests/README.md](tests/README.md) - Testing framework
- [.cursor/rules/](.cursor/rules/) - Workflow procedures
