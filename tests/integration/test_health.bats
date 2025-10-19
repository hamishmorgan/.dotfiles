#!/usr/bin/env bats
# Integration tests for health command

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
}

teardown() {
    teardown_test_dotfiles
}

@test "health command runs without crashing" {
    run ./dot health
    # May fail (exit 1) in test env due to missing deps, but should not crash
    # Exit code 1 is expected failure (unhealthy), not a crash
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "health command shows result status" {
    run ./dot health
    # May be unhealthy in test env, but should show result
    assert_output --partial "Result:"
}

@test "health command with backups shows correct size" {
    # Create test backups
    create_mock_backups 15 1

    run ./dot health
    # May fail overall, but should show backup info correctly

    # Should show backup count
    assert_output --partial "15 backups"

    # Should NOT show 0MB (Issue #66)
    refute_output --partial "0MB"

    # Should show reasonable size
    assert_output --regexp "[1-9][0-9]?MB"
}

@test "health command shows maintenance items with many backups" {
    # Create more than 10 backups to trigger maintenance warning
    create_mock_backups 12 1

    run ./dot health
    # Should show maintenance warning regardless of overall health

    assert_output --partial "backups using"
}

@test "health command verbose mode provides detailed output" {
    run ./dot health -v
    # May fail overall in test env

    # Should have more detailed information
    assert_output --partial "Dependencies"
}

@test "health command accepts -vv flag" {
    run ./dot health -vv
    # Should run without crashing (exit 0 or 1 both OK)
    [[ "$status" -eq 0 || "$status" -eq 1 ]]
}

@test "help flag shows usage" {
    run ./dot --help
    # Shows help and exits successfully
    assert_success
    assert_output --partial "Usage"
}

