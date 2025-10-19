#!/usr/bin/env bats

# Tests for automatic backup cleanup functionality

load '../test_helper/common'

setup() {
    setup_test_dotfiles
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "auto_cleanup_backups does nothing when backups <= MAX_BACKUPS_TO_KEEP" {
    create_mock_backups 5 1
    
    run auto_cleanup_backups
    assert_success
    
    # Verify no backups were removed
    local backup_count
    backup_count=$(get_backup_dirs | wc -l | tr -d ' ')
    assert_equal "5" "$backup_count"
}

@test "auto_cleanup_backups removes excess backups when threshold exceeded" {
    create_mock_backups 15 1
    
    run auto_cleanup_backups
    assert_success
    assert_output --partial "Auto cleanup"
    assert_output --partial "keeping 10 most recent"
    assert_output --partial "Removed 5 old backup(s)"
    
    # Verify correct number remain
    local backup_count
    backup_count=$(get_backup_dirs | wc -l | tr -d ' ')
    assert_equal "10" "$backup_count"
}

@test "auto_cleanup_backups keeps most recent backups" {
    create_mock_backups 12 1

    # Get oldest backup before cleanup
    local oldest_before
    oldest_before=$(get_backup_dirs | sort | head -1)

    run auto_cleanup_backups
    assert_success

    # Verify oldest was removed
    if [[ -d "$oldest_before" ]]; then
        fail "Oldest backup should have been removed: $oldest_before"
    fi

    # Verify newest still exists
    local newest
    newest=$(get_backup_dirs | sort -r | head -1)
    assert_dir_exists "$newest"
}

@test "clean_backups_silent removes backups without verbose output" {
    create_mock_backups 15 1
    
    BACKUP_KEEP_COUNT=5 run clean_backups_silent
    assert_success
    
    # Should only show final success message, no detailed output
    refute_output --partial "To Remove"
    refute_output --partial "dotfiles-backup-"
    assert_output --partial "Removed"
    
    # Verify correct count
    local backup_count
    backup_count=$(get_backup_dirs | wc -l | tr -d ' ')
    assert_equal "5" "$backup_count"
}

@test "auto_cleanup_backups integrates with install command" {
    create_mock_backups 15 1
    
    # Run auto cleanup directly (simulates install/update integration)
    run auto_cleanup_backups
    assert_success
    
    # Verify cleanup occurred
    local backup_count
    backup_count=$(get_backup_dirs | wc -l | tr -d ' ')
    [ "$backup_count" -le 10 ]
}

