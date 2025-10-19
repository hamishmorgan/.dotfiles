#!/usr/bin/env bats
# Unit tests for argument parsing functions

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "parse_verbosity handles invalid input" {
    run parse_verbosity "invalid"
    # Should fail for invalid input
    assert_failure
}

@test "parse_verbosity returns 1 for single -v" {
    run parse_verbosity "-v"
    assert_output "1"
}

@test "parse_verbosity returns 1 for --verbose" {
    run parse_verbosity "--verbose"
    assert_output "1"
}

@test "parse_verbosity returns 2 for -vv" {
    run parse_verbosity "-vv"
    assert_output "2"
}

@test "parse_verbosity handles -vvv" {
    run parse_verbosity "-vvv"
    assert_output "3"
}

@test "parse_verbosity handles -vvvv" {
    run parse_verbosity "-vvvv"
    assert_output "4"
}

@test "parse_verbosity only handles single flag" {
    # Function is designed to handle one flag at a time
    # parse_arguments does the accumulation
    run parse_verbosity "-v"
    assert_success
    assert_output "1"
}

