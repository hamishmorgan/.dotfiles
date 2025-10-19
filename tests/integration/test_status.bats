#!/usr/bin/env bats
# Integration tests for status command

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
}

teardown() {
    teardown_test_dotfiles
}

@test "status command exits successfully" {
    run ./dot status
    assert_success
}

@test "status command shows dotfiles location" {
    run ./dot status
    assert_success
    assert_output --partial "Location:"
}

@test "status command shows dependency status" {
    run ./dot status
    assert_success
    assert_output --partial "Dependencies"
}

@test "status command shows backup information" {
    # Create some backups
    create_mock_backups 5 1
    
    run ./dot status
    assert_success
    assert_output_contains "backups"
}

@test "status command runs quickly" {
    # Status should be fast (< 2 seconds)
    start=$(date +%s)
    run ./dot status
    end=$(date +%s)
    duration=$((end - start))
    
    assert_success
    [ "$duration" -lt 3 ]
}

