# BATS Testing Framework Structure (Example)

## Why BATS?
- TAP (Test Anything Protocol) output
- Easy test isolation with setup/teardown
- Good mocking/stubbing support
- Wide adoption in shell script projects
- Works with CI/CD

## Proposed Structure

```
tests/
├── unit/
│   ├── test_helper_functions.bats    # get_backup_stats, etc.
│   ├── test_logging.bats             # log_* functions
│   ├── test_validation.bats          # check_* functions
│   └── test_parsing.bats             # parse_* functions
├── integration/
│   ├── test_install.bats             # Full install command
│   ├── test_health.bats              # Health check outputs
│   ├── test_backup_restore.bats     # Backup/restore workflow
│   └── test_update.bats              # Update command
├── regression/
│   ├── test_issue_66.bats            # 0MB backup bug
│   └── test_issue_XX.bats            # Future regression tests
├── fixtures/
│   ├── mock_backups/                 # Test backup directories
│   ├── sample_configs/               # Test configuration files
│   └── expected_outputs/             # Expected command outputs
├── helpers/
│   ├── test_helper.bash              # Common test utilities
│   └── assertions.bash               # Custom assertions
├── smoke-test.sh                     # Keep existing (now calls BATS)
└── run-local-ci.sh                   # Keep existing
```

## Example Test Files

### tests/unit/test_helper_functions.bats
```bash
#!/usr/bin/env bats

load '../helpers/test_helper'

setup() {
    # Create temporary test environment
    TEST_DIR="$(mktemp -d)"
    export DOTFILES_DIR="$TEST_DIR"
    mkdir -p "$TEST_DIR/backups"
    
    # Source the functions we're testing
    source "$BATS_TEST_DIRNAME/../../dot"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "get_backup_stats returns correct count for empty directory" {
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    size=$(echo "$result" | cut -d' ' -f2)
    
    [ "$count" = "0" ]
    [ "$size" = "0" ]
}

@test "get_backup_stats returns correct count and size" {
    # Create test backups
    mkdir -p "$TEST_DIR/backups/dotfiles-backup-1"
    mkdir -p "$TEST_DIR/backups/dotfiles-backup-2"
    echo "test content" > "$TEST_DIR/backups/dotfiles-backup-1/file.txt"
    echo "more content" > "$TEST_DIR/backups/dotfiles-backup-2/file.txt"
    
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    size=$(echo "$result" | cut -d' ' -f2)
    
    [ "$count" = "2" ]
    [ "$size" -gt "0" ]
}

@test "get_backup_stats size calculation is accurate" {
    # Create backup with known size
    mkdir -p "$TEST_DIR/backups/dotfiles-backup-1"
    dd if=/dev/zero of="$TEST_DIR/backups/dotfiles-backup-1/file" bs=1024 count=100 2>/dev/null
    
    result="$(get_backup_stats)"
    size=$(echo "$result" | cut -d' ' -f2)
    
    # Size should be approximately 100KB (allowing for filesystem overhead)
    [ "$size" -ge "100" ]
    [ "$size" -le "110" ]
}
```

### tests/integration/test_health.bats
```bash
#!/usr/bin/env bats

load '../helpers/test_helper'

setup() {
    TEST_HOME="$(mktemp -d)"
    export HOME="$TEST_HOME"
    export DOTFILES_DIR="$(pwd)"
}

teardown() {
    rm -rf "$TEST_HOME"
}

@test "health command exits successfully" {
    run ./dot health
    [ "$status" -eq 0 ]
}

@test "health command shows backup size correctly" {
    # Create test backups
    mkdir -p backups/dotfiles-backup-test
    dd if=/dev/zero of=backups/dotfiles-backup-test/file bs=1M count=5 2>/dev/null
    
    run ./dot health
    [ "$status" -eq 0 ]
    
    # Check that output contains size in MB (not 0MB)
    [[ "$output" =~ [0-9]+MB ]]
    [[ ! "$output" =~ "0MB" ]]
    
    # Cleanup
    rm -rf backups/dotfiles-backup-test
}

@test "health command maintenance items show when backups > 10" {
    # Create 11 test backup directories
    for i in {1..11}; do
        mkdir -p "backups/dotfiles-backup-test$i"
        echo "test" > "backups/dotfiles-backup-test$i/file"
    done
    
    run ./dot health
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Maintenance Items" ]]
    [[ "$output" =~ "backups using" ]]
    
    # Cleanup
    rm -rf backups/dotfiles-backup-test*
}

@test "health verbose mode provides detailed output" {
    run ./dot health -v
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Dependencies" ]]
    [[ "$output" =~ "Package Status" ]]
}
```

### tests/regression/test_issue_66.bats
```bash
#!/usr/bin/env bats

# Regression test for Issue #66: Backup size showing as 0MB
# https://github.com/hamishmorgan/.dotfiles/issues/66

load '../helpers/test_helper'

setup() {
    TEST_DIR="$(mktemp -d)"
    export DOTFILES_DIR="$TEST_DIR"
    mkdir -p "$TEST_DIR/backups"
}

teardown() {
    rm -rf "$TEST_DIR"
}

@test "Issue #66: backup size displays correctly in maintenance items" {
    # Create 15 backups with known size
    for i in {1..15}; do
        mkdir -p "$TEST_DIR/backups/dotfiles-backup-$i"
        dd if=/dev/zero of="$TEST_DIR/backups/dotfiles-backup-$i/file" bs=1M count=1 2>/dev/null
    done
    
    cd "$TEST_DIR"
    run "$BATS_TEST_DIRNAME/../../dot" health
    
    [ "$status" -eq 0 ]
    
    # Verify backup count is correct
    [[ "$output" =~ "15 backups" ]]
    
    # Verify size is NOT 0MB (the bug)
    [[ ! "$output" =~ "using 0MB" ]]
    
    # Verify size is reasonable (at least 10MB for 15 x 1MB files)
    [[ "$output" =~ "using "[1-9][0-9]?"MB" ]]
}

@test "Issue #66: backup_size_kb variable is defined and used correctly" {
    # Source the script to access internal functions
    source "$BATS_TEST_DIRNAME/../../dot"
    
    # Create test backups
    mkdir -p "$TEST_DIR/backups/dotfiles-backup-1"
    echo "test" > "$TEST_DIR/backups/dotfiles-backup-1/file"
    
    # Call get_backup_stats and verify both values are returned
    result="$(get_backup_stats)"
    
    # Should have two space-separated values
    count=$(echo "$result" | wc -w)
    [ "$count" -eq 2 ]
    
    # Both values should be numeric
    backup_count=$(echo "$result" | cut -d' ' -f1)
    backup_size_kb=$(echo "$result" | cut -d' ' -f2)
    
    [[ "$backup_count" =~ ^[0-9]+$ ]]
    [[ "$backup_size_kb" =~ ^[0-9]+$ ]]
}
```

### tests/helpers/test_helper.bash
```bash
# Common test helper functions

# Create a mock dotfiles directory structure
setup_mock_dotfiles() {
    local dir="$1"
    mkdir -p "$dir"/{system,git,zsh,tmux,gh,gnuplot,bash,fish}
    mkdir -p "$dir/backups"
    mkdir -p "$dir/tests"
    
    # Create minimal dot script
    cp "$BATS_TEST_DIRNAME/../dot" "$dir/dot"
}

# Create mock backup directories
create_mock_backups() {
    local backup_dir="$1"
    local count="$2"
    local size_mb="${3:-1}"
    
    for i in $(seq 1 "$count"); do
        local backup="$backup_dir/dotfiles-backup-$i"
        mkdir -p "$backup"
        dd if=/dev/zero of="$backup/file" bs=1M count="$size_mb" 2>/dev/null
    done
}

# Assert output contains pattern
assert_output_contains() {
    local pattern="$1"
    [[ "$output" =~ $pattern ]] || {
        echo "Expected output to contain: $pattern"
        echo "Actual output: $output"
        return 1
    }
}

# Assert output does not contain pattern
assert_output_not_contains() {
    local pattern="$1"
    [[ ! "$output" =~ $pattern ]] || {
        echo "Expected output to NOT contain: $pattern"
        echo "Actual output: $output"
        return 1
    }
}

# Assert numeric value is in range
assert_in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    
    [ "$value" -ge "$min" ] && [ "$value" -le "$max" ] || {
        echo "Expected $value to be between $min and $max"
        return 1
    }
}
```

## Installation & Setup

```bash
# Install BATS
# macOS
brew install bats-core

# Ubuntu
sudo apt-get install bats

# Or install from source
git clone https://github.com/bats-core/bats-core.git
cd bats-core
./install.sh /usr/local

# Install helper libraries
git clone https://github.com/bats-core/bats-support tests/bats-support
git clone https://github.com/bats-core/bats-assert tests/bats-assert
```

## Running Tests

```bash
# Run all tests
bats tests/

# Run specific test file
bats tests/unit/test_helper_functions.bats

# Run with TAP output
bats --tap tests/

# Run with timing
bats --timing tests/

# Parallel execution
bats --jobs 4 tests/
```

## CI Integration

```yaml
# .github/workflows/test.yml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Install BATS
        run: |
          sudo apt-get update
          sudo apt-get install -y bats
      
      - name: Run unit tests
        run: bats tests/unit/
      
      - name: Run integration tests
        run: bats tests/integration/
      
      - name: Run regression tests
        run: bats tests/regression/
```

## Benefits

1. **Catch bugs early**: Unit tests would have caught the 0MB bug
2. **Confidence in refactoring**: Change code knowing tests will catch breaks
3. **Documentation**: Tests serve as examples of expected behavior
4. **Regression prevention**: Add test for each bug fix
5. **CI/CD integration**: Automated testing on every commit
6. **Fast feedback**: Unit tests run in seconds

## Test Coverage Goals

- **Unit tests**: 80%+ coverage of helper functions
- **Integration tests**: All major commands (install, health, update, backup, restore)
- **Regression tests**: One test per fixed bug
- **Smoke tests**: Continue as quick sanity check

