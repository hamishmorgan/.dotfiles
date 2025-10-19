#!/usr/bin/env bats
# Integration tests for health command

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
}

teardown() {
    teardown_test_dotfiles
}

@test "health command exits successfully" {
    run ./dot health
    assert_success
}

@test "health command shows result status" {
    run ./dot health
    assert_success
    assert_output --partial "Result:"
}

@test "health command with backups shows correct size" {
    # Create test backups
    create_mock_backups 15 1
    
    run ./dot health
    assert_success
    
    # Should show backup count
    assert_output_contains "15 backups"
    
    # Should NOT show 0MB (Issue #66)
    assert_output_not_contains "0MB"
    
    # Should show reasonable size
    assert_output --regexp "[1-9][0-9]?MB"
}

@test "health command shows maintenance items with many backups" {
    # Create more than 10 backups to trigger maintenance warning
    create_mock_backups 12 1
    
    run ./dot health
    assert_success
    
    assert_output_contains "Maintenance Items"
    assert_output_contains "backups using"
}

@test "health command verbose mode provides detailed output" {
    run ./dot health -v
    assert_success
    
    # Should have more detailed information
    assert_output_contains "Dependencies"
    assert_output_contains "Package Status"
}

@test "health command accepts -vv flag" {
    run ./dot health -vv
    assert_success
}

@test "health command accepts --help flag" {
    run ./dot health --help
    # Should fail (shows help and exits)
    assert_failure
    assert_output --partial "Usage"
}

