#!/usr/bin/env bats
# Contract tests for health command output format

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
}

teardown() {
    teardown_test_dotfiles
}

@test "health output has required sections" {
    run ./dot health
    assert_success
    
    # Check for all required sections
    assert_output_contains "Dependencies"
    assert_output_contains "Package Status"
    assert_output_contains "Symlink Health"
    assert_output_contains "Backup Health"
    assert_output_contains "Result:"
}

@test "health output has proper status symbols" {
    run ./dot health
    assert_success
    
    # Should use status symbols (color codes or actual symbols)
    # At minimum should have checkmarks or status indicators
    [[ "$output" =~ (✓|✗|∙|⚠) ]] || [[ "$output" =~ (HEALTHY|pass|fail|info) ]]
}

@test "health verbose output includes detailed information" {
    run ./dot health -v
    assert_success
    
    # Verbose should have more details
    assert_output_contains "Checking"
    
    # Should be longer than non-verbose
    verbose_lines=$(echo "$output" | wc -l)
    [ "$verbose_lines" -gt 10 ]
}

@test "health output format is consistent" {
    # Run twice, output format should be consistent
    run ./dot health
    output1="$output"
    
    run ./dot health
    output2="$output"
    
    # Both should have same structure (section headers)
    [[ "$output1" =~ "Dependencies" ]] && [[ "$output2" =~ "Dependencies" ]]
    [[ "$output1" =~ "Result:" ]] && [[ "$output2" =~ "Result:" ]]
}

