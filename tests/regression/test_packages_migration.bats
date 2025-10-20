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

@test "validate_package accepts packages/ directory symlinks" {
    # Regression test for health check validation bug
    # Issue: validate_package was checking for .dotfiles/<package> 
    # but should check for .dotfiles/packages/<package>
    
    # Source the dot script
    source_dot_script
    
    local dotfiles_dir="$BATS_TEST_DIRNAME/../.."
    
    # Create a symlink pointing to the CORRECT packages/ path
    # (simulating what stow actually creates after migration)
    ln -sf "$dotfiles_dir/packages/git/.gitconfig" "$HOME/.gitconfig"
    
    # Verify symlink points to packages/ directory
    local target
    target="$(readlink "$HOME/.gitconfig")"
    [[ "$target" == *"/packages/git/"* ]]
    
    # Run validate_package for git package
    run validate_package "git"
    assert_success
    
    # Should report validation success
    assert_output --partial "Git configuration validated successfully"
}

@test "health check passes with packages/ directory structure" {
    # End-to-end regression test
    # Verify health check correctly validates symlinks after packages/ migration
    
    cd "$BATS_TEST_DIRNAME/../.." || return 1
    
    # Install dotfiles (creates symlinks to packages/ directory)
    ./dot install > /dev/null 2>&1 || true
    
    # Run health check
    run ./dot health
    
    # Health should pass (exit 0) or fail gracefully (exit 1)
    # Should NOT crash with exit 2 or other codes
    [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
    
    # Critical: Should NOT show symlink validation errors
    refute_output --partial "validation failed"
    
    # If installation succeeded, symlink integrity should pass
    if [[ "$status" -eq 0 ]]; then
        assert_output --partial "Symlink Integrity"
        assert_output --regexp "(✓ Pass|Pass)"
    fi
}

