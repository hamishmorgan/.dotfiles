#!/usr/bin/env bats
# Unit tests for backup-related functions

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "get_backup_stats returns 0 0 for empty directory" {
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    size=$(echo "$result" | cut -d' ' -f2)
    
    assert_equal "$count" "0"
    assert_equal "$size" "0"
}

@test "get_backup_stats counts backups correctly" {
    create_mock_backups 5 1
    
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    
    assert_equal "$count" "5"
}

@test "get_backup_stats calculates size correctly" {
    # Create 1MB backup
    mkdir -p "$TEST_DOTFILES_DIR/backups/dotfiles-backup-test"
    dd if=/dev/zero of="$TEST_DOTFILES_DIR/backups/dotfiles-backup-test/file" bs=1M count=1 2>/dev/null
    
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    size=$(echo "$result" | cut -d' ' -f2)
    
    assert_equal "$count" "1"
    # Size should be approximately 1024KB (allowing for filesystem overhead)
    assert_in_range "$size" 1000 1100
}

@test "get_backup_stats handles multiple backups" {
    create_mock_backups 10 2
    
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    size=$(echo "$result" | cut -d' ' -f2)
    
    assert_equal "$count" "10"
    # 10 backups × 2MB = ~20MB = ~20480KB (allowing for overhead)
    assert_in_range "$size" 20000 21000
}

@test "get_backup_stats ignores non-backup directories" {
    create_mock_backups 3 1
    mkdir -p "$TEST_DOTFILES_DIR/backups/not-a-backup"
    echo "should be ignored" > "$TEST_DOTFILES_DIR/backups/not-a-backup/file"
    
    result="$(get_backup_stats)"
    count=$(echo "$result" | cut -d' ' -f1)
    
    # Should only count the 3 actual backups
    assert_equal "$count" "3"
}

@test "get_backup_dirs lists backup directories" {
    create_mock_backups 3 1
    
    result="$(get_backup_dirs)"
    line_count=$(echo "$result" | wc -l)
    
    assert_equal "$line_count" "3"
}

@test "get_backup_dirs returns empty for no backups" {
    result="$(get_backup_dirs)"
    
    # Should be empty (or just whitespace)
    [ -z "$(echo "$result" | tr -d '[:space:]')" ]
}

