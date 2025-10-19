# Testing Strategy for Dotfiles

## Problem Statement

The 0MB backup size bug (Issue #66) wasn't caught by existing tests. We need comprehensive testing to prevent similar issues.

## Testing Framework Comparison

### Option 1: BATS (Bash Automated Testing System) ⭐ **RECOMMENDED**

**Pros:**
- Most popular bash testing framework
- Excellent documentation and community
- TAP output (Test Anything Protocol)
- Easy setup/teardown hooks
- Works great with CI/CD
- Can test functions in isolation

**Cons:**
- Additional dependency to install
- Learning curve for TAP format

**Best for:** Unit tests, integration tests, regression tests

### Option 2: shellspec

**Pros:**
- BDD-style syntax (describe/it blocks)
- Very readable tests
- Good mocking support
- Coverage reporting

**Cons:**
- Less widely adopted than BATS
- More opinionated structure

**Best for:** Teams preferring BDD style

### Option 3: shunit2

**Pros:**
- Part of many Linux distros
- xUnit-style (familiar to many developers)
- Mature and stable

**Cons:**
- Less active development
- Fewer features than BATS

**Best for:** Simple unit testing

### Option 4: Custom Test Framework (current approach)

**Pros:**
- No dependencies
- Full control
- Simple to understand

**Cons:**
- Have to build everything ourselves
- No standard output format
- Limited assertion library

**Best for:** Minimal testing needs

## Recommended Approach: BATS + Custom Helpers

**Phase 1: Foundation (Week 1)**
1. Install BATS and helper libraries
2. Create test structure
3. Write regression test for Issue #66
4. Set up CI integration

**Phase 2: Core Coverage (Week 2-3)**
1. Unit tests for all helper functions
2. Integration tests for main commands
3. Output validation tests

**Phase 3: Comprehensive (Week 4+)**
1. Property-based tests
2. Performance tests
3. Cross-platform validation
4. Documentation

## Test Categories

### 1. Unit Tests (Fast, Isolated)

Test individual functions in isolation.

**Examples:**
```bash
# tests/unit/test_backup_stats.bats
@test "get_backup_stats with empty directory returns 0 0" {
    result="$(get_backup_stats)"
    [ "$result" = "0 0" ]
}

@test "get_backup_stats calculates size correctly" {
    # Create 1MB backup
    mkdir -p backups/test-backup
    dd if=/dev/zero of=backups/test-backup/file bs=1M count=1
    
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    size=$(echo "$result" | cut -d' ' -f2)
    
    [ "$count" = "1" ]
    [ "$size" -ge "1000" ]  # At least 1000KB
}
```

### 2. Integration Tests (Medium, End-to-End)

Test full command workflows.

**Examples:**
```bash
# tests/integration/test_health_command.bats
@test "health command with backups shows correct size" {
    # Setup: Create 15 backups of 1MB each
    for i in {1..15}; do
        mkdir -p backups/dotfiles-backup-$i
        dd if=/dev/zero of=backups/dotfiles-backup-$i/file bs=1M count=1
    done
    
    run ./dot health
    
    # Assertions
    [ "$status" -eq 0 ]
    assert_output_contains "15 backups"
    assert_output_not_contains "0MB"
    assert_output_contains "[0-9]+MB"
}
```

### 3. Regression Tests (Prevent Past Bugs)

One test per bug fix.

**Examples:**
```bash
# tests/regression/test_issue_66_backup_size.bats
@test "Issue #66: Maintenance items show correct backup size, not 0MB" {
    # This would have caught the backup_size vs backup_size_kb bug
    
    create_mock_backups backups 15 1
    
    run ./dot health
    [ "$status" -eq 0 ]
    
    # The bug: showed "0MB" 
    # The fix: shows actual size like "15MB"
    assert_output_not_contains "using 0MB"
    assert_output_matches "using [1-9][0-9]*MB"
}
```

### 4. Contract Tests (Output Validation)

Verify command outputs match expected formats.

**Examples:**
```bash
# tests/contract/test_health_output.bats
@test "health command output has required sections" {
    run ./dot health
    
    assert_output_contains "Dependencies"
    assert_output_contains "Package Status"
    assert_output_contains "Symlink Health"
    assert_output_contains "Backup Health"
    assert_output_contains "Result:"
}

@test "health verbose output includes detailed information" {
    run ./dot health -v
    
    assert_output_contains "Checking dependency:"
    assert_output_contains "Package:"
}
```

### 5. Property Tests (Invariants)

Test properties that should always be true.

**Examples:**
```bash
# tests/property/test_invariants.bats
@test "get_backup_stats always returns two numbers" {
    run get_backup_stats
    
    # Should always return "count size"
    [ "$(echo "$output" | wc -w)" -eq 2 ]
    
    count=$(echo "$output" | cut -d' ' -f1)
    size=$(echo "$output" | cut -d' ' -f2)
    
    # Both should be numeric
    [[ "$count" =~ ^[0-9]+$ ]]
    [[ "$size" =~ ^[0-9]+$ ]]
}

@test "backup count equals number of backup directories" {
    # Create random number of backups
    n=$((RANDOM % 20 + 1))
    create_mock_backups backups "$n" 1
    
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    
    [ "$count" = "$n" ]
}

@test "total backup size equals sum of individual sizes" {
    create_mock_backups backups 5 1
    
    # Get total from function
    result="$(get_backup_stats)"
    total=$(echo "$result" | cut -d' ' -f2)
    
    # Calculate manually
    manual_sum=0
    for dir in backups/dotfiles-backup-*; do
        size=$(du -sk "$dir" | cut -f1)
        ((manual_sum += size))
    done
    
    [ "$total" = "$manual_sum" ]
}
```

## Practical Implementation Plan

### Step 1: Quick Win - Add BATS Regression Test

Create a single test file that would have caught the 0MB bug:

```bash
# tests/regression/test_issue_66.bats
#!/usr/bin/env bats

@test "Issue #66: backup size not 0MB" {
    # Create test setup
    mkdir -p backups
    for i in {1..15}; do
        mkdir -p "backups/dotfiles-backup-$i"
        echo "test data" > "backups/dotfiles-backup-$i/file"
    done
    
    run ./dot health
    
    # This assertion would have failed before the fix
    [[ ! "$output" =~ "using 0MB" ]]
    
    # Cleanup
    rm -rf backups/dotfiles-backup-*
}
```

Run with: `bats tests/regression/test_issue_66.bats`

### Step 2: Add to CI

```yaml
# .github/workflows/validate.yml (add to existing)
  regression-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Install BATS
        run: sudo apt-get install -y bats
      - name: Run regression tests
        run: bats tests/regression/
```

### Step 3: Gradual Expansion

Add tests incrementally:
1. Week 1: Regression tests for any new bugs
2. Week 2: Unit tests for helper functions
3. Week 3: Integration tests for main commands
4. Week 4: Contract tests for output formats

## Testing Pyramid

```
       /\
      /  \     E2E Tests (Slow, Brittle)
     /----\    5% - Full workflow scenarios
    /      \   
   /--------\  Integration Tests (Medium)
  /          \ 25% - Command-level testing
 /------------\
/______________\ Unit Tests (Fast, Focused)
                70% - Function-level testing
```

## Metrics to Track

1. **Test Count**: Target 100+ tests
2. **Coverage**: Target 80%+ of functions
3. **Speed**: Unit tests < 1s, Integration < 10s
4. **Flakiness**: < 1% failure rate on reruns
5. **Bug Detection**: Every bug should have a regression test

## Example: Full Test Suite Structure

```
tests/
├── unit/                           # 70% of tests
│   ├── test_backup_functions.bats
│   ├── test_logging.bats
│   ├── test_parsing.bats
│   └── test_validation.bats
├── integration/                    # 25% of tests
│   ├── test_install.bats
│   ├── test_health.bats
│   ├── test_update.bats
│   └── test_backup_restore.bats
├── regression/                     # One per bug
│   ├── test_issue_66.bats
│   └── test_issue_XX.bats
├── contract/                       # Output validation
│   ├── test_health_output.bats
│   └── test_status_output.bats
├── property/                       # Invariants
│   └── test_invariants.bats
├── e2e/                           # 5% of tests
│   └── test_full_workflow.bats
├── fixtures/                       # Test data
│   ├── mock_configs/
│   └── expected_outputs/
├── helpers/                        # Test utilities
│   ├── test_helper.bash
│   └── assertions.bash
└── TESTING_STRATEGY.md            # This file
```

## Tools & Resources

**BATS:**
- Repository: https://github.com/bats-core/bats-core
- Docs: https://bats-core.readthedocs.io/
- Support libraries: bats-support, bats-assert, bats-file

**Alternatives:**
- shellspec: https://github.com/shellspec/shellspec
- shunit2: https://github.com/kward/shunit2

**CI Integration:**
- GitHub Actions examples: https://github.com/bats-core/bats-core#github-actions
- Coverage reporting: kcov + codecov

## Next Steps

1. **Immediate**: Create regression test for Issue #66
2. **This week**: Add BATS to project, set up structure
3. **Next sprint**: Add unit tests for top 10 most critical functions
4. **Ongoing**: Add regression test for every bug fix

## Questions to Consider

1. What's our target test coverage percentage?
2. How much time can we invest in testing?
3. Should we gate PRs on test passage?
4. Do we need code coverage reporting?
5. Should we add performance benchmarks?

