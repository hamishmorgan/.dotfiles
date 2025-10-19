#!/usr/bin/env bats
# Unit tests for package management functions

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR"
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "get_package_files returns correct files for system" {
    result="$(get_package_files "system")"
    
    [[ "$result" =~ \.stow-global-ignore ]]
    [[ "$result" =~ \.stowrc ]]
    [[ "$result" =~ \.editorconfig ]]
    [[ "$result" =~ \.inputrc ]]
}

@test "get_package_files returns correct files for git" {
    result="$(get_package_files "git")"
    
    [[ "$result" =~ \.gitconfig ]]
    [[ "$result" =~ \.gitattributes ]]
    [[ "$result" =~ \.gitignore-globals ]]
}

@test "get_package_files returns correct files for fish" {
    result="$(get_package_files "fish")"
    
    [[ "$result" =~ \.config/fish ]]
}

@test "get_package_files returns empty for unknown package" {
    result="$(get_package_files "nonexistent")"
    
    [ "$result" = "" ]
}

@test "get_package_name returns correct display name" {
    [ "$(get_package_name "system")" = "System" ]
    [ "$(get_package_name "git")" = "Git" ]
    [ "$(get_package_name "zsh")" = "Zsh" ]
    [ "$(get_package_name "fish")" = "Fish" ]
}

@test "get_package_name returns package name for unknown package" {
    result="$(get_package_name "unknown")"
    [ "$result" = "unknown" ]
}

@test "get_required_deps returns common dependencies" {
    result="$(get_required_deps "common")"
    
    [[ "$result" =~ stow ]]
    [[ "$result" =~ git ]]
}

@test "get_required_deps returns optional dependencies" {
    result="$(get_required_deps "optional")"
    
    [[ "$result" =~ tmux ]]
    [[ "$result" =~ zsh ]]
    [[ "$result" =~ fish ]]
}

