#!/usr/bin/env bats
# Contract tests for status command output format

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
}

teardown() {
    teardown_test_dotfiles
}

@test "status output has installed files section" {
    run ./dot status
    assert_success
    
    assert_output --partial "Installed Files"
}

@test "status output has dotfiles title" {
    run ./dot status
    assert_success
    
    assert_output --partial "Installation Status"
}

@test "status output has backup information" {
    run ./dot status
    assert_success

    # Should show either "No backups" or backup count
    assert_output --regexp "(backup|Backup)"
}

@test "status output is concise" {
    run ./dot status
    assert_success

    # Status should be brief (< 50 lines typically)
    line_count=$(echo "$output" | wc -l)
    [ "$line_count" -lt 100 ]
}

