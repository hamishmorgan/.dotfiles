# Dotfiles Testing Framework

Comprehensive testing framework for validating dotfiles installation across platforms.

## Quick Start

```bash
# Run smoke tests (fast, local)
./tests/smoke-test.sh

# Run full cross-platform tests (requires Docker)
./tests/run-local-ci.sh
```

## Test Categories

1. **Regression Tests** - One per bug, written BEFORE fix
2. **Unit Tests** - Test functions in isolation
3. **Integration Tests** - Test complete commands
4. **Contract Tests** - Validate output format
5. **Smoke Tests** - Fast structural validation

## Testing Strategy

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
- Tests on Bash 3.2 (macOS default bash version)
- Complete install → validate → health cycle
- Secret file processing
- Symlink verification

**Usage:**

```bash
# Test all platforms (default, ~6-9 minutes)
./tests/run-local-ci.sh
# or
./dev/ci

# Test specific platform for quick iteration (~2-3 minutes)
./dev/ci ubuntu      # Quick Ubuntu check
./dev/ci alpine      # BSD compatibility check
./dev/ci bash32      # macOS compatibility check

# Keep test images for debugging
./dev/ci all --no-cleanup
```

**Platform Selection:**

- **`ubuntu`**: Test on Ubuntu 22.04 (matches GitHub Actions environment)
- **`alpine`**: Test on Alpine (BSD-like coreutils, catches macOS compatibility issues)
- **`bash32`**: Test on Bash 3.2 (macOS default bash version)
- **`all`**: Test on all platforms (comprehensive validation)

**When to run:**
- Single platform: During development for quick iteration
- All platforms: Before pushing to GitHub for comprehensive validation

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

- bash 3.2+ (works with macOS default bash)
- shellcheck (optional, will skip if not available)
- markdownlint (optional, will skip if not available)

### For Container Tests

- Docker or Podman installed and running
- 2GB disk space for images
- Internet connection (first run downloads images)

**Note:** Test framework auto-detects and works with both Docker and Podman.

### Disk Space Management

Test images are automatically cleaned up after each test run to prevent disk space accumulation.
If needed, manually clean up container storage:

```bash
# For Docker
docker system prune -a -f --volumes

# For Podman
podman system prune -a -f --volumes

# If podman commands fail with electron errors, use clean environment:
env -i PATH=/usr/bin:/bin HOME=$HOME podman system prune -a -f --volumes
```

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

### Bash 3.2 Container

- Based on `ubuntu:20.04` with Bash 3.2.57 compiled from source
- Tests compatibility with macOS default bash
- Ensures no Bash 4.0+ features are used
- Validates version check in dot script

### Bash 3.2 Compatibility

The dot script is designed for Bash 3.2 compatibility (macOS default).

**Test Bash 3.2 locally:**

```bash
./tests/run-local-ci.sh bash32
```

**What we avoid:**

- Associative arrays (`declare -A`) - Bash 4.0+
- `mapfile` / `readarray` - Bash 4.0+
- `&>>` redirect - Bash 4.0+

**What we use instead:**

- Functions for key-value storage
- `while read` loops
- Separate redirects (`> file 2>&1`)

## Troubleshooting

### Container Tests Fail

```bash
# Rebuild images from scratch (replace 'docker' with 'podman' if using Podman)
docker rmi dotfiles-test-ubuntu dotfiles-test-alpine dotfiles-test-bash32
./tests/run-local-ci.sh
```

### Disk Space Issues

If disk fills up from container overlays:

```bash
# Check disk usage
df -h

# Clean all container data (replace 'docker' with 'podman' if using Podman)
docker system prune -a -f --volumes

# For podman with environment interference:
env -i PATH=/usr/bin:/bin HOME=$HOME podman system prune -a -f --volumes
```

Note: Test script now automatically cleans up images after each run to prevent accumulation.

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

## Reference

For procedural testing workflow (when to write tests, TDD pattern, critical principles, running tests),
see `.cursor/rules/testing-workflow.mdc`.

For comprehensive testing framework documentation, see DEVELOPMENT.md Testing section.
