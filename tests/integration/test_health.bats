#!/usr/bin/env bats
# Integration tests for health command

load ../test_helper/common

setup() {
    setup_test_dotfiles
    # Isolate HOME to prevent modifying actual user directory
    export HOME="$TEST_DOTFILES_DIR/home"
    mkdir -p "$HOME"
    cd "$TEST_DOTFILES_DIR" || return 1
}

teardown() {
    teardown_test_dotfiles
}

@test "health command completes successfully" {
    # Test in isolation by installing dotfiles first
    ./dot install > /dev/null 2>&1 || true
    
    run ./dot health
    # Health command must either pass or fail cleanly (not crash)
    # Acceptable exit codes: 0 (healthy) or 1 (unhealthy)
    # Any other code indicates a crash/error
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    
    # Must always show result section
    assert_output --partial "Result:"
}

@test "health command shows backup information correctly" {
    # Create test backups
    create_mock_backups 15 1
    
    # Install dotfiles for complete environment
    ./dot install > /dev/null 2>&1 || true

    run ./dot health
    # With installation, health should now pass or be unhealthy
    # (unhealthy is OK if backups > 10 or other warnings)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    
    # Should show backup information (count may vary due to installation backup)
    assert_output --regexp "[0-9]+ backups"
    
    # Should NOT show 0MB (Issue #66 - the key regression test)
    refute_output --partial "0MB)"
    
    # Should show reasonable non-zero size
    assert_output --regexp "[1-9][0-9]?MB"
}

@test "health command shows maintenance warnings" {
    # Create more than 10 backups to trigger maintenance warning
    create_mock_backups 12 1
    
    ./dot install > /dev/null 2>&1 || true

    run ./dot health
    # Should complete (even if unhealthy due to backups)
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    
    assert_output --partial "backups using"
}

@test "health command verbose mode works" {
    ./dot install > /dev/null 2>&1 || true
    
    run ./dot health -v
    # Verbose mode must complete
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    
    # Should have detailed information
    assert_output --partial "Checking"
}

@test "health command accepts verbosity flags" {
    run ./dot health -vv
    # Must complete without crashing
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "help flag shows usage" {
    run ./dot --help
    # Shows help and exits successfully
    assert_success
    assert_output --partial "Usage"
}

