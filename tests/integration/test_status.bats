#!/usr/bin/env bats
# Integration tests for status command

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
}

teardown() {
    teardown_test_dotfiles
}

@test "status command exits successfully" {
    run ./dot status
    [ "$status" -eq 0 ]
}

@test "status command shows dotfiles location" {
    run ./dot status
    [ "$status" -eq 0 ]
    assert_output_contains "Location:"
}

@test "status command shows dependency status" {
    run ./dot status
    [ "$status" -eq 0 ]
    assert_output_contains "Dependencies"
}

@test "status command shows backup information" {
    # Create some backups
    create_mock_backups 5 1

    run ./dot status
    [ "$status" -eq 0 ]
    assert_output_contains "backups"
}

@test "status command runs quickly" {
    # Status should be fast (< 2 seconds)
    start=$(date +%s)
    run ./dot status
    end=$(date +%s)
    duration=$((end - start))

    [ "$status" -eq 0 ]
    [ "$duration" -lt 3 ]
}

