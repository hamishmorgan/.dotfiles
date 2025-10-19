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

@test "Issue #66: get_backup_stats shows size correctly, not 0" {
    # Setup: Create 15 backups with 1MB each  
    create_mock_backups 15 1
    
    # Test the function directly (the bug was in this function)
    cd "$TEST_DOTFILES_DIR"
    source_dot_script
    
    run get_backup_stats
    assert_success
    
    # Should return "count size" format
    # Extract count and size
    count=$(echo "$output" | awk '{print $1}')
    size_kb=$(echo "$output" | awk '{print $2}')
    
    # The bug: size was 0
    # After fix: size is non-zero
    assert_equal "15" "$count"
    [ "$size_kb" -gt 0 ]  # Size must be greater than 0 (the actual bug fix)
    [ "$size_kb" -gt 10000 ]  # Should be at least 10MB = 10000KB for 15x1MB backups
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

@test "Issue #66: backup size calculation is correct in KB" {
    # Create 20 backups to verify size calculation
    create_mock_backups 20 1

    cd "$TEST_DOTFILES_DIR"
    source_dot_script
    
    # Get backup stats
    result=$(get_backup_stats)
    count=$(echo "$result" | awk '{print $1}')
    size_kb=$(echo "$result" | awk '{print $2}')
    
    # Verify count
    assert_equal "20" "$count"
    
    # The bug: backup_size_kb variable was not used correctly
    # After fix: size_kb is calculated and returned correctly
    [ "$size_kb" -gt 0 ]  # Must not be zero
    [ "$size_kb" -gt 15000 ]  # Should be at least 15MB for 20x1MB backups
    
    # Calculate MB from KB for verification
    size_mb=$((size_kb / 1024))
    [ "$size_mb" -ge 15 ]  # At least 15MB
}

@test "Issue #66: backup stats helper returns correct values" {
    create_mock_backups 12 1
    
    cd "$TEST_DOTFILES_DIR"
    source_dot_script
    
    # Test the helper function that formats backup stats
    result=$(get_backup_stats)
    
    # Should return two values: count and size_kb
    word_count=$(echo "$result" | wc -w)
    [ "$word_count" -eq 2 ]
    
    count=$(echo "$result" | awk '{print $1}')
    size_kb=$(echo "$result" | awk '{print $2}')
    
    # Verify both values are correct
    assert_equal "12" "$count"
    [ "$size_kb" -gt 10000 ]  # At least 10MB for 12x1MB backups
}

