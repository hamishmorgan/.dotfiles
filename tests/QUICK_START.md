# Quick Start: Add Regression Test for Issue #66

This guide shows you how to add a single regression test that would have caught the 0MB backup bug.

## Option A: No Framework - Pure Bash (Fastest)

Create a simple regression test with zero dependencies:

```bash
# tests/regression/test_backup_size_bug.sh
#!/bin/bash

TEST_DIR="$(mktemp -d)"
trap "rm -rf '$TEST_DIR'" EXIT

echo "Testing: Backup size displays correctly (Issue #66)"

# Setup: Create 15 test backups
mkdir -p "$TEST_DIR/backups"
for i in {1..15}; do
    mkdir -p "$TEST_DIR/backups/dotfiles-backup-$i"
    dd if=/dev/zero of="$TEST_DIR/backups/dotfiles-backup-$i/file" bs=1M count=1 2>/dev/null
done

# Run health command with test directory
cd "$TEST_DIR"
cp "$OLDPWD/dot" .
output=$(./dot health 2>&1)

# Check for the bug
if echo "$output" | grep -q "using 0MB"; then
    echo "❌ FAIL: Backup size showing as 0MB (bug present)"
    exit 1
fi

# Check size is reasonable (should be ~15MB)
if echo "$output" | grep -qE "using [1-9][0-9]?MB"; then
    echo "✅ PASS: Backup size displays correctly"
    exit 0
else
    echo "❌ FAIL: Backup size not displaying"
    exit 1
fi
```

Run it:
```bash
chmod +x tests/regression/test_backup_size_bug.sh
./tests/regression/test_backup_size_bug.sh
```

Add to CI (`.github/workflows/validate.yml`):
```yaml
- name: Run regression tests
  run: |
    for test in tests/regression/*.sh; do
      bash "$test" || exit 1
    done
```

## Option B: BATS Framework (More Features)

### 1. Install BATS

```bash
# macOS
brew install bats-core

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install bats

# Verify
bats --version
```

### 2. Create Regression Test

```bash
# tests/regression/test_issue_66.bats
#!/usr/bin/env bats

# Regression test for Issue #66
# Bug: Health check showed "0MB" instead of actual backup size
# Cause: Used undefined variable $backup_size instead of $backup_size_kb

setup() {
    # Create temporary test environment
    export TEST_DIR="$(mktemp -d)"
    export DOTFILES_DIR="$TEST_DIR"
    mkdir -p "$TEST_DIR/backups"
    
    # Copy dot script to test directory
    cp "$BATS_TEST_DIRNAME/../../dot" "$TEST_DIR/"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "Issue #66: health command shows backup size, not 0MB" {
    # Setup: Create 15 backups with 1MB each
    for i in {1..15}; do
        mkdir -p "$TEST_DIR/backups/dotfiles-backup-$i"
        dd if=/dev/zero of="$TEST_DIR/backups/dotfiles-backup-$i/file" \
           bs=1M count=1 2>/dev/null
    done
    
    # Run health command
    cd "$TEST_DIR"
    run ./dot health
    
    # Should succeed
    [ "$status" -eq 0 ]
    
    # Should show backup count
    [[ "$output" =~ "15 backups" ]]
    
    # The bug: showed "using 0MB"
    # After fix: shows actual size like "using 15MB" or "using 196MB"
    if [[ "$output" =~ "using 0MB" ]]; then
        echo "BUG DETECTED: Showing 0MB (Issue #66)"
        return 1
    fi
    
    # Should show reasonable size (at least 10MB for 15x1MB)
    [[ "$output" =~ "using "[1-9][0-9]?"MB" ]]
}

@test "Issue #66: get_backup_stats returns both count and size" {
    # Source the dot script to test internal functions
    cd "$TEST_DIR"
    source ./dot
    
    # Create test backup
    mkdir -p "$TEST_DIR/backups/dotfiles-backup-1"
    echo "test data" > "$TEST_DIR/backups/dotfiles-backup-1/file"
    
    # Call the function
    result="$(get_backup_stats)"
    
    # Should return two space-separated numbers
    local word_count=$(echo "$result" | wc -w)
    [ "$word_count" -eq 2 ]
    
    # Extract values
    local count=$(echo "$result" | cut -d' ' -f1)
    local size=$(echo "$result" | cut -d' ' -f2)
    
    # Both should be numbers
    [[ "$count" =~ ^[0-9]+$ ]]
    [[ "$size" =~ ^[0-9]+$ ]]
    
    # Count should be 1
    [ "$count" = "1" ]
    
    # Size should be greater than 0
    [ "$size" -gt 0 ]
}
```

### 3. Run the Test

```bash
# Run single test file
bats tests/regression/test_issue_66.bats

# Run all regression tests
bats tests/regression/

# Run with TAP output
bats --tap tests/regression/test_issue_66.bats

# Run with timing
bats --timing tests/regression/test_issue_66.bats
```

Expected output:
```
✓ Issue #66: health command shows backup size, not 0MB
✓ Issue #66: get_backup_stats returns both count and size

2 tests, 0 failures
```

### 4. Add to CI

```yaml
# .github/workflows/validate.yml
name: CI

on: [push, pull_request]

jobs:
  regression-tests:
    name: Regression Tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install BATS
        run: sudo apt-get update && sudo apt-get install -y bats
      
      - name: Run regression tests
        run: bats tests/regression/
```

## Comparison

| Feature | Pure Bash | BATS |
|---------|-----------|------|
| Setup time | 5 minutes | 15 minutes |
| Dependencies | None | BATS |
| Test isolation | Manual | Automatic |
| Output format | Custom | TAP standard |
| Setup/teardown | Manual | Built-in |
| Assertions | Manual | Helper libraries |
| CI integration | Simple | Standard |
| Debugging | Print statements | Verbose mode |
| **Recommendation** | Quick one-offs | Long-term testing |

## Recommendation

**Start with Pure Bash** for immediate regression test:
- Zero setup time
- No new dependencies
- Catches the bug immediately

**Migrate to BATS** when adding more tests:
- Better structure
- Standard output format
- Easier to maintain many tests

## Next Steps

1. ✅ Create regression test for Issue #66
2. Run it locally to verify it works
3. Add to CI
4. **Rule**: Every future bug fix must include a regression test
5. Gradually add unit tests for critical functions
6. Consider full BATS migration when you have 10+ tests

## Example: Gradual Migration

```
Week 1: Add regression test for Issue #66 (Pure Bash)
Week 2: Bug fix #2 → Add regression test (Pure Bash)
Week 3: Bug fix #3 → Add regression test (Pure Bash)
Week 4: Now have 3 tests → Convert to BATS
Week 5+: All new tests use BATS framework
```

This way you get immediate value (catching regressions) while building toward comprehensive testing.

