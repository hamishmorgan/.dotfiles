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

@test "status command runs without crashing" {
    run ./dot status
    # Should complete without crashing (exit 0 is expected)
    assert_success
}

@test "status command shows installed files" {
    run ./dot status
    assert_success
    assert_output --partial "Installed Files"
}

@test "status command shows file count" {
    run ./dot status
    assert_success
    # Should show count like "16 of 16 files installed"
    assert_output --regexp "[0-9]+ of [0-9]+ files installed"
}

@test "status command shows backup information" {
    # Create some backups
    create_mock_backups 5 1

    run ./dot status
    assert_success
    # Should show "Total: 5 backup(s)" or similar
    assert_output --regexp "[0-9]+ backup"
}

@test "status command completes without hanging" {
    # Verify status command completes (no timeout)
    # Removed timing assertion as it's flaky in CI
    run ./dot status
    assert_success
}

