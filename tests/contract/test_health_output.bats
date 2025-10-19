#!/usr/bin/env bats
# Contract tests for health command output format

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
}

teardown() {
    teardown_test_dotfiles
}

@test "health output has required sections" {
    run ./dot health
    # May fail in test env, but should have proper structure

    # Check for all required sections (actual output format)
    assert_output --partial "Symlink Integrity"
    assert_output --partial "Dependencies"
    assert_output --partial "Backup Health"
    assert_output --partial "Result:"
}

@test "health output has proper status symbols" {
    run ./dot health
    assert_success

    # Should use status symbols (color codes or actual symbols)
    # At minimum should have checkmarks or status indicators
    assert_output --regexp "(✓|✗|∙|⚠|HEALTHY|pass|fail|info)"
}

@test "health verbose output includes detailed information" {
    run ./dot health -v
    assert_success

    # Verbose should have more details
    assert_output --partial "Checking"
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

