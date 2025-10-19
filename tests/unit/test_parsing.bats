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
    result="$(parse_verbosity)"
    [ "$result" = "0" ]
}

@test "parse_verbosity returns 1 for single -v" {
    result="$(parse_verbosity "-v")"
    [ "$result" = "1" ]
}

@test "parse_verbosity returns 1 for --verbose" {
    result="$(parse_verbosity "--verbose")"
    [ "$result" = "1" ]
}

@test "parse_verbosity returns 2 for -vv" {
    result="$(parse_verbosity "-vv")"
    [ "$result" = "2" ]
}

@test "parse_verbosity returns 2 for -v -v" {
    result="$(parse_verbosity "-v" "-v")"
    [ "$result" = "2" ]
}

@test "parse_verbosity returns 2 for --verbose --verbose" {
    result="$(parse_verbosity "--verbose" "--verbose")"
    [ "$result" = "2" ]
}

@test "parse_verbosity caps at 2" {
    result="$(parse_verbosity "-v" "-v" "-v")"
    [ "$result" = "2" ]
}

