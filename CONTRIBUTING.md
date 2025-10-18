# Contributing to .dotfiles

Contribution guidelines for this dotfiles repository.

## Table of Contents

- [Development Setup](#development-setup)
- [Code Standards](#code-standards)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Code of Conduct](#code-of-conduct)

## Development Setup

### Prerequisites

- Bash 3.2+
- Git 2.0+
- GNU Stow 2.3+
- Docker or Podman (for local CI testing)

### Initial Setup

```bash
# Fork and clone
git clone git@github.com:YOUR_USERNAME/.dotfiles.git
cd .dotfiles

# Run smoke tests
./tests/smoke-test.sh

# Run full CI locally
./tests/run-local-ci.sh
```

## Code Standards

### Bash Style Guide

1. **Use shellcheck**: All bash code must pass shellcheck
2. **POSIX-compatible short flags**: Use `-p` not `--parents`
3. **Long-form for stow**: Use `--verbose` not `-v`
4. **Bash 3.2 compatible**: No associative arrays, no mapfile
5. **Functions over scripts**: Prefer functions in dot script
6. **Error handling**: Explicit error handling, avoid `set -e`

### Example

```bash
# Good
install_package() {
    local package="$1"
    
    if [[ ! -d "$package" ]]; then
        log_error "Package not found: $package"
        return 1
    fi
    
    if ! stow --verbose --restow "$package"; then
        log_error "Failed to install: $package"
        return 1
    fi
    
    log_success "Installed: $package"
    return 0
}

# Bad (bash 4.0+)
declare -A packages=([git]=1 [zsh]=1)  # No associative arrays
```

### Documentation Style

Per AGENTS.md:

- Formal, minimal, reserved tone
- Technically precise language
- Eliminate unnecessary words
- No marketing language or exclamations
- Direct and concise

### Commit Messages

Follow conventional commits:

```text
type(scope): brief description

Longer description if needed.

- Bullet points for details
- Multiple changes listed

Benefits:
- Benefit 1
- Benefit 2
```

## Testing

### Before Committing

```bash
# Run smoke tests (30 seconds)
./tests/smoke-test.sh
```

### Before Pushing

```bash
# Run full CI locally (2-3 minutes)
./tests/run-local-ci.sh
```

### Test Requirements

- All smoke tests must pass
- Shellcheck must be clean
- Markdownlint must pass
- Local CI must pass on Ubuntu and Alpine

## Pull Request Process

1. **Create feature branch**: `git checkout -b feature/your-feature`
2. **Make changes**: Follow code standards
3. **Test locally**: Run smoke tests and local CI
4. **Commit**: Use conventional commits
5. **Create PR**: Use GitHub MCP or web interface
6. **Request Copilot review**: Use `mcp_github_request_copilot_review`
7. **Wait for CI**: Monitor CI status
8. **Address feedback**: Fix any Copilot or CI issues
9. **Repeat**: Until both CI and Copilot approve
10. **Merge**: Only after all checks pass

### PR Template

```markdown
## Summary

Brief description of changes

## Changes

- Change 1
- Change 2

## Testing

- [ ] Smoke tests passing
- [ ] Local CI passing
- [ ] Shellcheck clean
- [ ] Tested on macOS/Linux

## Related Issues

Fixes #X
```

## Issue Reporting

### Bug Reports

```markdown
**Description**
Clear description of the bug

**To Reproduce**
1. Run ./dot install
2. See error

**Expected Behavior**
What should happen

**Environment**
- OS: macOS 14.0 / Ubuntu 22.04
- Bash version: 3.2 / 5.1
- Stow version: 2.3.1

**Additional Context**
Any other relevant information
```

### Feature Requests

Use provided template with:

- Problem statement
- Proposed solution
- Benefits
- Priority assessment

## Code of Conduct

Be respectful, professional, and constructive in all interactions.

## Questions?

Open an issue or discussion for any questions about contributing.
