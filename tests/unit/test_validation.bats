#!/usr/bin/env bats
# Unit tests for validation functions

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "command_exists returns success for existing command" {
    run command_exists "bash"
    assert_success
}

@test "command_exists returns failure for non-existing command" {
    run command_exists "this-command-does-not-exist-12345"
    assert_failure
}

@test "count_orphaned_symlinks runs without crashing" {
    # Note: count_orphaned_symlinks checks $HOME for broken symlinks
    # Isolating HOME causes test execution issues in BATS
    # This test verifies the function runs without error
    run count_orphaned_symlinks
    assert_success
    # Output is a count (0 or more)
    assert_output --regexp "^[0-9]+$"
}

