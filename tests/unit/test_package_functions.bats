#!/usr/bin/env bats
# Unit tests for package management functions

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "get_package_files returns correct files for system" {
    run get_package_files "system"

    assert_output --partial ".stow-global-ignore"
    assert_output --partial ".stowrc"
    assert_output --partial ".editorconfig"
    assert_output --partial ".inputrc"
}

@test "get_package_files returns correct files for git" {
    run get_package_files "git"

    assert_output --partial ".gitconfig"
    assert_output --partial ".gitattributes"
    assert_output --partial ".gitignore-globals"
}

@test "get_package_files returns correct files for fish" {
    run get_package_files "fish"

    assert_output --partial ".config/fish"
}

@test "get_package_files returns empty for unknown package" {
    run get_package_files "nonexistent"

    assert_output ""
}

@test "get_package_name returns correct display name" {
    run get_package_name "system"
    assert_output "System"

    run get_package_name "git"
    assert_output "Git"

    run get_package_name "zsh"
    assert_output "Zsh"

    run get_package_name "fish"
    assert_output "Fish"
}

@test "get_package_name returns package name for unknown package" {
    run get_package_name "unknown"
    assert_output "unknown"
}

@test "get_required_deps returns common dependencies" {
    run get_required_deps "common"

    assert_output --partial "stow"
    assert_output --partial "git"
}

@test "get_required_deps returns optional dependencies" {
    run get_required_deps "optional"

    assert_output --partial "tmux"
    assert_output --partial "zsh"
    assert_output --partial "fish"
}

