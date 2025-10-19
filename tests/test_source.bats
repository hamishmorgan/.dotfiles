#!/usr/bin/env bats

load test_helper/common

setup() {
    export TEST_DOTFILES_DIR="$(mktemp -d)"
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"
    mkdir -p "$TEST_DOTFILES_DIR"
    cp dot "$TEST_DOTFILES_DIR/"
}

teardown() {
    rm -rf "$TEST_DOTFILES_DIR"
}

@test "can source dot script" {
    cd "$TEST_DOTFILES_DIR"
    export BATS_TESTING=1
    run source ./dot
    echo "Status: $status"
    echo "Output: $output"
    [ "$status" -eq 0 ]
}

