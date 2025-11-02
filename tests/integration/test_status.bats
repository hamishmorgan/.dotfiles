#!/usr/bin/env bats
# Integration tests for status command

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

@test "status command works correctly" {
    # Run status once and check all requirements
    # This is faster than running status multiple times
    run ./dot status
    # Should complete without crashing (exit 0 is expected)
    assert_success

    # Check for required sections
    assert_output --partial "Installed Packages"
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

