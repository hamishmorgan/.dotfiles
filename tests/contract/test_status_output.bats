#!/usr/bin/env bats
# Contract tests for status command output format

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
}

teardown() {
    teardown_test_dotfiles
}

@test "status output format is correct" {
    # Run status once and check all format requirements
    # This is faster than running status multiple times
    run ./dot status
    assert_success

    # Check for all required sections in one test
    assert_output --partial "Installed Packages"
    assert_output --partial "Installation Status"
    assert_output --regexp "(backup|Backup)"

    # Status should be brief (< 100 lines typically)
    line_count=$(echo "$output" | wc -l)
    [ "$line_count" -lt 100 ]
}

