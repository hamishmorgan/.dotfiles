#!/usr/bin/env bats
# Regression test for Issue #66: Backup size showing as 0MB
# Bug: Health check maintenance items showed "using 0MB" instead of actual backup size
# Cause: Used undefined variable $backup_size instead of $backup_size_kb
# Fixed in: commit c25fa39

load ../test_helper/common

setup() {
    setup_test_dotfiles
}

teardown() {
    teardown_test_dotfiles
}

@test "Issue #66: health command shows backup size, not 0MB" {
    # Setup: Create 15 backups with 1MB each  
    create_mock_backups 15 1
    
    # Run health command
    cd "$TEST_DOTFILES_DIR"
    run ./dot health
    
    # Health may fail due to missing deps/symlinks in test env, but should still show backup info
    # The key is that backup size is displayed correctly
    
    # Should show backup count
    assert_output --partial "15 backups"
    
    # The bug: showed "using 0MB" 
    # After fix: shows actual size like "using 15MB"
    refute_output --partial "using 0MB"
    
    # Should show reasonable size (at least 10MB for 15x1MB)
    assert_output --regexp "using [1-9][0-9]?MB"
}

@test "Issue #66: get_backup_stats returns both count and size" {
    # Source the dot script to test internal functions
    cd "$TEST_DOTFILES_DIR"
    source_dot_script

    # Create test backup
    mkdir -p "$TEST_DOTFILES_DIR/backups/dotfiles-backup-1"
    echo "test data" > "$TEST_DOTFILES_DIR/backups/dotfiles-backup-1/file"

    # Call the function
    result="$(get_backup_stats)"

    # Should return two space-separated numbers
    local word_count=$(echo "$result" | wc -w)
    [ "$word_count" -eq 2 ]

    # Extract values
    local count=$(echo "$result" | cut -d' ' -f1)
    local size=$(echo "$result" | cut -d' ' -f2)

    # Both should be numbers
    assert_numeric "$count"
    assert_numeric "$size"

    # Count should be 1
    [ "$count" = "1" ]

    # Size should be greater than 0
    [ "$size" -gt 0 ]
}

@test "Issue #66: backup_size_kb variable is used correctly in maintenance items" {
    # Create many backups to trigger maintenance warning
    create_mock_backups 20 1

    cd "$TEST_DOTFILES_DIR"
    run ./dot health
    
    # Health may fail in test env, but should still show backup info correctly
    # The critical test is that backup size is not 0MB
    
    # Should show backup warning with non-zero size
    assert_output --regexp "20 backups using [1-9][0-9]?MB"
    
    # Should not show 0MB (the bug)
    refute_output --partial "using 0MB"
}

@test "Issue #66: verbose health also shows correct backup size" {
    create_mock_backups 12 1
    
    cd "$TEST_DOTFILES_DIR"
    run ./dot health -v
    
    # Health may fail in test env, key is backup display
    # Verbose mode should also show backups correctly
    assert_output --partial "12 backups"
    assert_output --regexp "using [1-9][0-9]?MB"
}

