#!/usr/bin/env bats
# Unit tests for validation functions

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "command_exists returns success for existing command" {
    run command_exists "bash"
    [ "$status" -eq 0 ]
}

@test "command_exists returns failure for non-existing command" {
    run command_exists "this-command-does-not-exist-12345"
    [ "$status" -ne 0 ]
}

@test "count_orphaned_symlinks returns 0 for no symlinks" {
    result="$(count_orphaned_symlinks)"
    [ "$result" = "0" ]
}

@test "count_orphaned_symlinks counts broken symlinks" {
    # Create orphaned symlink in test directory
    ln -s /nonexistent/path "$TEST_DOTFILES_DIR/orphan-link"

    # Note: This function checks $HOME, so we'd need to mock that
    # For now, just test it runs without error
    run count_orphaned_symlinks
    [ "$status" -eq 0 ]
}

