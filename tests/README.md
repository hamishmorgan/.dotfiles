# Dotfiles Testing Framework

Comprehensive testing framework for validating dotfiles installation across platforms.

## Quick Start

```bash
# Run smoke tests (fast, local)
./tests/smoke-test.sh

# Run full cross-platform tests (requires Docker)
./tests/run-local-ci.sh
```

## Test Types

### Smoke Tests

Fast validation of basic functionality:

- Script execution and help display
- Package definitions and structure
- Template and ignore files exist
- Shellcheck and markdownlint pass
- Symbol-based logging present

**Usage:**

```bash
./tests/smoke-test.sh
```

**When to run:** Before committing changes

### Docker-Based Integration Tests

Full installation and validation in clean environments:

- Tests on Ubuntu 22.04 (matches GitHub Actions)
- Tests on Alpine (BSD-like coreutils, catches macOS issues)
- Complete install → validate → health cycle
- Secret file processing
- Symlink verification

**Usage:**

```bash
# Test both platforms
./tests/run-local-ci.sh

# Test specific platform
./tests/run-local-ci.sh ubuntu
./tests/run-local-ci.sh alpine
```

**When to run:** Before pushing to GitHub

## Testing Workflow

```mermaid
Code Change → Smoke Test → Docker Tests → Push → GitHub Actions
```

1. **Make changes** to dot script or configs
2. **Run smoke test**: `./tests/smoke-test.sh` (30 seconds)
3. **Run Docker tests**: `./tests/run-local-ci.sh` (2-3 minutes)
4. **Push to GitHub** with confidence
5. **GitHub Actions** validates on real Ubuntu and macOS

## Requirements

### For Smoke Tests

- bash 4.0+
- shellcheck (optional, will skip if not available)
- markdownlint (optional, will skip if not available)

### For Container Tests

- Docker or Podman installed and running
- 2GB disk space for images
- Internet connection (first run downloads images)

**Note:** Test framework auto-detects and works with both Docker and Podman.

## Container Test Details

### Ubuntu Container

- Based on `ubuntu:22.04`
- Matches GitHub Actions environment
- Uses GNU coreutils (long-form arguments work)
- Tests standard Linux installation

### Alpine Container

- Based on `alpine:3.19`
- Uses BusyBox coreutils (BSD-like)
- Catches macOS compatibility issues
- Tests with minimal POSIX-only commands

## Troubleshooting

### Container Tests Fail

```bash
# Rebuild images from scratch (replace 'docker' with 'podman' if using Podman)
docker rmi dotfiles-test-ubuntu dotfiles-test-alpine
./tests/run-local-ci.sh
```

### Want More Detail

```bash
# Run container interactively (replace 'docker' with 'podman' if using Podman)
docker run --rm -it \
  -v "$PWD:/dotfiles:ro" \
  dotfiles-test-ubuntu \
  bash

# Then inside container:
cp -r /dotfiles ~/.dotfiles
cd ~/.dotfiles
./dot install
```

## Future Enhancements

- Add bats-based unit tests
- Test rollback functionality
- Test conflict handling
- Test with existing dotfiles
- Performance benchmarks
