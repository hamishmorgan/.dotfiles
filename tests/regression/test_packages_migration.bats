#!/usr/bin/env bats
# Regression test for packages/ directory migration
# Issue: update command should fix broken symlinks after directory reorganization

load '../test_helper/common'

@test "remove_mispointed_symlinks removes broken symlinks" {
    # Source the dot script to get the function
    source_dot_script
    
    # Create broken symlink (points to non-existent file)
    ln -sf "$BATS_TEST_TMPDIR/nonexistent/file" "$HOME/.broken_link"
    
    # Verify it's broken
    [[ ! -e "$HOME/.broken_link" ]]
    [[ -L "$HOME/.broken_link" ]]
    
    # Run function
    run remove_mispointed_symlinks 0
    assert_success
    
    # Broken symlink should be removed
    [[ ! -L "$HOME/.broken_link" ]]
}

@test "remove_mispointed_symlinks removes old-style package symlinks" {
    # Source the dot script
    source_dot_script
    
    # Get the actual DOTFILES_DIR and PACKAGES_DIR from the script
    local dotfiles_dir="$BATS_TEST_DIRNAME/../.."
    
    # Create symlink pointing to OLD package path (bash/ instead of packages/bash/)
    ln -sf "$dotfiles_dir/bash/.bashrc" "$HOME/.bashrc_old_style"
    
    # This symlink points to DOTFILES_DIR but NOT to PACKAGES_DIR
    local target
    target="$(readlink "$HOME/.bashrc_old_style")"
    [[ "$target" == "$dotfiles_dir/"* ]]
    [[ "$target" != "$dotfiles_dir/packages/"* ]]
    
    # Run cleanup function
    run remove_mispointed_symlinks 0
    assert_success
    
    # Old-style symlink should be removed
    [[ ! -L "$HOME/.bashrc_old_style" ]]
}

@test "remove_mispointed_symlinks preserves correct symlinks" {
    # Source the dot script
    source_dot_script
    
    local dotfiles_dir="$BATS_TEST_DIRNAME/../.."
    
    # Create symlink pointing to CORRECT packages/ path
    mkdir -p "$BATS_TEST_TMPDIR/fake-packages/git"
    echo "[user]" > "$BATS_TEST_TMPDIR/fake-packages/git/.gitconfig"
    
    # Simulate correct path (contains packages/)
    ln -sf "$BATS_TEST_TMPDIR/fake-packages/git/.gitconfig" "$HOME/.gitconfig_correct"
    
    # Run cleanup
    run remove_mispointed_symlinks 0
    assert_success
    
    # Correct symlink should be PRESERVED
    [[ -L "$HOME/.gitconfig_correct" ]]
}

@test "remove_mispointed_symlinks handles .config directory" {
    # Source the dot script  
    source_dot_script
    
    local dotfiles_dir="$BATS_TEST_DIRNAME/../.."
    
    # Create broken symlink in .config
    mkdir -p "$HOME/.config/gh"
    ln -sf "$dotfiles_dir/gh/.config/gh/config.yml" "$HOME/.config/gh/config.yml"
    
    # This points to OLD path (gh/ not packages/gh/)
    local target
    target="$(readlink "$HOME/.config/gh/config.yml")"
    [[ "$target" != *"/packages/"* ]]
    
    # Run cleanup
    run remove_mispointed_symlinks 0
    assert_success
    
    # Should be removed
    [[ ! -L "$HOME/.config/gh/config.yml" ]]
}

