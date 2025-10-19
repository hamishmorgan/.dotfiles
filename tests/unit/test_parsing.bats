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

@test "parse_verbosity returns 0 for no flags" {
    run parse_verbosity
    assert_output "0"
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

@test "parse_verbosity returns 2 for -v -v" {
    run parse_verbosity "-v" "-v"
    assert_output "2"
}

@test "parse_verbosity returns 2 for --verbose --verbose" {
    run parse_verbosity "--verbose" "--verbose"
    assert_output "2"
}

@test "parse_verbosity caps at 2" {
    run parse_verbosity "-v" "-v" "-v"
    assert_output "2"
}

