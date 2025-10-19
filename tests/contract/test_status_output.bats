#!/usr/bin/env bats
# Contract tests for status command output format

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
}

teardown() {
    teardown_test_dotfiles
}

@test "status output has location information" {
    run ./dot status
    assert_success
    
    assert_output_contains "Location:"
}

@test "status output has dependencies section" {
    run ./dot status
    assert_success
    
    assert_output_contains "Dependencies"
}

@test "status output has backup information" {
    run ./dot status
    assert_success
    
    # Should show either "No backups" or backup count
    [[ "$output" =~ (backup|Backup) ]]
}

@test "status output is concise" {
    run ./dot status
    assert_success
    
    # Status should be brief (< 50 lines typically)
    line_count=$(echo "$output" | wc -l)
    [ "$line_count" -lt 100 ]
}

