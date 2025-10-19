# Test Framework Documentation

## Overview

Comprehensive BATS-based testing framework for the dotfiles repository.

## Test Structure

```
tests/
├── bats/                     # BATS core (submodule)
├── test_helper/
│   ├── bats-support/         # Helper library (submodule)
│   ├── bats-assert/          # Assertion library (submodule)
│   └── common.bash           # Custom helpers
├── unit/                     # Unit tests (70% of tests)
│   ├── test_backup_functions.bats
│   ├── test_package_functions.bats
│   ├── test_parsing.bats
│   └── test_validation.bats
├── integration/              # Integration tests (25% of tests)
│   ├── test_health.bats
│   ├── test_status.bats
│   └── test_backup_restore.bats
├── regression/               # Regression tests (one per bug)
│   └── test_issue_66.bats
├── contract/                 # Output validation tests
│   ├── test_health_output.bats
│   └── test_status_output.bats
└── run-bats.sh              # Run all tests locally
```

## Running Tests

### All Tests

```bash
# Using the script
./tests/run-bats.sh

# Or directly with BATS
tests/bats/bin/bats tests/
```

### Specific Test Suite

```bash
# Unit tests
tests/bats/bin/bats tests/unit/

# Integration tests
tests/bats/bin/bats tests/integration/

# Regression tests
tests/bats/bin/bats tests/regression/

# Contract tests
tests/bats/bin/bats tests/contract/
```

### Single Test File

```bash
tests/bats/bin/bats tests/regression/test_issue_66.bats
```

### With Timing

```bash
tests/bats/bin/bats --timing tests/
```

### Parallel Execution

```bash
tests/bats/bin/bats --jobs 4 tests/
```

## Test Categories

### Unit Tests (70%)
Test individual functions in isolation.

**Example:**
```bash
@test "get_backup_stats returns correct count" {
    create_mock_backups 5 1
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    assert_equal "$count" "5"
}
```

### Integration Tests (25%)
Test complete commands end-to-end.

**Example:**
```bash
@test "health command exits successfully" {
    run ./dot health
    assert_success
}
```

### Regression Tests
One test per fixed bug to prevent recurrence.

**Example:**
```bash
@test "Issue #66: backup size not 0MB" {
    create_mock_backups 15 1
    run ./dot health
    assert_output_not_contains "using 0MB"
}
```

### Contract Tests
Ensure output format stability.

**Example:**
```bash
@test "health output has required sections" {
    run ./dot health
    assert_output_contains "Dependencies"
    assert_output_contains "Result:"
}
```

## Writing Tests

### Basic Test Structure

```bash
#!/usr/bin/env bats

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
}

teardown() {
    teardown_test_dotfiles
}

@test "descriptive test name" {
    # Arrange: Set up test conditions
    create_mock_backups 5 1
    
    # Act: Run the code being tested
    run ./dot health
    
    # Assert: Verify the results
    assert_success
    assert_output_contains "5 backups"
}
```

### Available Assertions

From **bats-assert**:
- `assert_success` - Exit code is 0
- `assert_failure` - Exit code is non-zero
- `assert_equal "expected" "actual"`
- `assert_output "expected"` - Exact match
- `assert_output --partial "substring"` - Substring match
- `assert_output --regexp "pattern"` - Regex match

From **common.bash**:
- `assert_output_contains "pattern"`
- `assert_output_not_contains "pattern"`
- `assert_in_range VALUE MIN MAX`
- `assert_numeric "string"`

### Helper Functions

From **common.bash**:
- `setup_test_dotfiles` - Create temporary test environment
- `teardown_test_dotfiles` - Clean up test environment
- `create_mock_backups COUNT SIZE_MB` - Create test backups
- `source_dot_script` - Load dot script functions
- `get_actual_backup_count` - Get actual backup count
- `get_actual_backup_size` - Get actual backup size in KB

## CI Integration

Tests run automatically in GitHub Actions:
- On every push to main or feature branches
- On every pull request

See `.github/workflows/test.yml` for configuration.

## Test Coverage

**Current Status:**
- Unit tests: 20+ tests
- Integration tests: 10+ tests
- Regression tests: 4+ tests
- Contract tests: 6+ tests

**Total: 40+ tests**

## Guidelines

### When to Write Tests

1. **Always:** Add regression test for every bug fix
2. **New features:** Add unit tests for new functions
3. **Commands:** Add integration test for new commands
4. **Output changes:** Update contract tests

### Test Naming

- Use descriptive names: `@test "health command shows backup size correctly"`
- Include issue numbers in regression tests: `@test "Issue #66: ..."`
- Be specific: Not "test health", but "health command exits successfully"

### Test Isolation

- Each test should be independent
- Use `setup()` and `teardown()` hooks
- Don't rely on test execution order
- Clean up after yourself

### Performance

- Unit tests should run in < 1 second
- Integration tests in < 5 seconds
- Keep test suite under 2 minutes total

## Troubleshooting

### Tests Failing Locally

```bash
# Initialize submodules
git submodule update --init --recursive

# Check BATS is available
tests/bats/bin/bats --version
```

### Tests Pass Locally But Fail in CI

- Check platform differences (Ubuntu vs macOS)
- Verify all dependencies are installed in CI
- Look at CI logs for specific errors

### Slow Tests

```bash
# Run with timing to identify slow tests
tests/bats/bin/bats --timing tests/
```

## References

- **BATS Documentation:** https://bats-core.readthedocs.io/
- **bats-support:** https://github.com/bats-core/bats-support
- **bats-assert:** https://github.com/bats-core/bats-assert
- **Issue #24:** Testing framework tracking issue
- **Issue #66:** First bug caught by testing strategy

## Next Steps

1. ✅ Write regression test for every bug
2. ✅ Maintain 80%+ test coverage
3. ✅ Keep tests fast and reliable
4. ✅ Update tests when changing functionality

