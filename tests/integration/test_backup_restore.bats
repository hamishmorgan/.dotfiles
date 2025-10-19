#!/usr/bin/env bats
# Integration tests for backup and restore commands

load ../test_helper/common

setup() {
    setup_test_dotfiles
    export HOME="$TEST_DOTFILES_DIR/home"
    mkdir -p "$HOME"
    cd "$TEST_DOTFILES_DIR" || return 1
}

teardown() {
    teardown_test_dotfiles
}

@test "backup command exits successfully" {
    # Create a file to backup
    echo "test" > "$HOME/.testfile"

    run ./dot backup
    [ "$status" -eq 0 ]
}

@test "backup command creates backup directory" {
    echo "test" > "$HOME/.testfile"

    ./dot backup >/dev/null 2>&1

    # Should have created a backup
    backup_count=$(find "$TEST_DOTFILES_DIR/backups" -type d -name "dotfiles-backup-*" | wc -l)
    [ "$backup_count" -gt 0 ]
}

@test "backups command lists backups" {
    create_mock_backups 3 1

    run ./dot backups
    [ "$status" -eq 0 ]
}

@test "backups command shows backup count" {
    create_mock_backups 5 1

    run ./dot backups
    [ "$status" -eq 0 ]
    # Should mention we have backups
    assert_output_contains "backup"
}

