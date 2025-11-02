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
git commit -m "type(scope): description"

# Types: feat, fix, docs, style, refactor, perf, test, chore
# Example: git commit -m "feat(packages): add rust configuration"
```

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
gh pr create
```

Wait for CI, address review feedback, iterate until approved.

## Adding a New Package

```bash
# 1. Create structure
mkdir -p packages/PACKAGE_NAME
cat > packages/PACKAGE_NAME/manifest.toml << 'EOF'
files = [".config/tool/config.yml"]
name = "Package Name"
description = "Brief description"
method = "stow"
target = "~"
EOF

# 2. Add config files
cp ~/.config/tool/config.yml packages/PACKAGE_NAME/.config/tool/

# 3. Create .stow-local-ignore
cat > packages/PACKAGE_NAME/.stow-local-ignore << 'EOF'
^manifest\.toml$
^README\.md$
\.example$
\.local$
EOF

# 4. Create README.md (see existing package READMEs for template)

# 5. Test
./dot enable PACKAGE_NAME && ./dot health -v

# 6. Add to README.md Packages table
# | **PACKAGE_NAME** | Brief description |

# 7. Submit
git add packages/PACKAGE_NAME
git commit -m "feat(packages): add PACKAGE_NAME"
gh pr create
```

## Fixing Bugs

**Test-Driven Development (REQUIRED):**

1. Create failing regression test in `tests/regression/test_issue_XX.bats`
2. Verify test fails
3. Fix the bug
4. Verify test passes
5. Commit test and fix together

See [.cursor/rules/testing-workflow.mdc](.cursor/rules/testing-workflow.mdc) for detailed pattern and examples.

## Code Standards

**Bash:** 3.2 compatible, 2-space indent, explicit error handling, no `set -e`

**Avoid:** Associative arrays, `mapfile`, `&>>` (all Bash 4.0+)

**Documentation:** Formal, minimal, technically precise

See [DEVELOPMENT.md](DEVELOPMENT.md) for comprehensive code standards.

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

Update relevant files for changes:

- **README.md** - User-facing features
- **DEVELOPMENT.md** - Architecture, testing
- **COMMANDS.md** - Commands
- **AGENTS.md** - AI patterns
- **Package README** - Package-specific

## Getting Help

Open issues for questions, bugs, or feature requests. Use GitHub Discussions for broader topics.

## Additional Resources

- [DEVELOPMENT.md](DEVELOPMENT.md) - Developer documentation
- [COMMANDS.md](COMMANDS.md) - Command reference
- [AGENTS.md](AGENTS.md) - AI agent instructions
- [tests/README.md](tests/README.md) - Testing framework
- [.cursor/rules/](.cursor/rules/) - Workflow procedures
