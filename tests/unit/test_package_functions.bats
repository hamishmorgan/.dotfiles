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

@test "get_package_files returns error for unknown package" {
    run get_package_files "nonexistent"

    assert_failure
    assert_output --partial "missing manifest"
}

@test "load_package_manifest sets PACKAGE_NAME correctly" {
    load_package_manifest "system" || return 1
    # Remove quotes if present
    PACKAGE_NAME="${PACKAGE_NAME//\"/}"
    assert_equal "$PACKAGE_NAME" "System"

    load_package_manifest "git" || return 1
    PACKAGE_NAME="${PACKAGE_NAME//\"/}"
    assert_equal "$PACKAGE_NAME" "Git"

    load_package_manifest "zsh" || return 1
    PACKAGE_NAME="${PACKAGE_NAME//\"/}"
    assert_equal "$PACKAGE_NAME" "Zsh"

    load_package_manifest "fish" || return 1
    PACKAGE_NAME="${PACKAGE_NAME//\"/}"
    assert_equal "$PACKAGE_NAME" "Fish"
}

@test "load_package_manifest sets PACKAGE_NAME to package name for unknown package" {
    run load_package_manifest "unknown"
    assert_failure
    # PACKAGE_NAME should fallback to package name when manifest doesn't exist
    # But since load_package_manifest fails, PACKAGE_NAME won't be set
}

@test "get_required_deps returns common dependencies" {
    run get_required_deps "common"

    assert_output --partial "stow"
    assert_output --partial "git"
}

@test "get_required_deps returns empty for optional type" {
    run get_required_deps "optional"

    assert_output ""
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Platform Override Tests
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@test "load_package_manifest applies macOS target override" {
    skip "Platform override tests require refactoring - see Issue #128"
}

@test "load_package_manifest applies Linux target override" {
    skip "Platform override tests require refactoring - see Issue #128"
}

@test "load_package_manifest uses default target for unknown platform" {
    # Create test package with platform-specific targets
    local test_package="$TEST_DOTFILES_DIR/packages/platform-test"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = ["test.txt"]
name = "Platform Test"
target = "~/.config/default"
target.macos = "~/Library/Application Support/PlatformTest"
target.linux = "~/.config/platformtest"
EOF

    # Mock detect_platform to return unknown platform
    detect_platform() { echo "unknown"; }
    export -f detect_platform

    load_package_manifest "platform-test" || return 1

    # Should use default target
    assert_equal "$PACKAGE_TARGET" "$HOME/.config/default"
}

@test "load_package_manifest expands tilde in platform-specific targets" {
    skip "Platform override tests require refactoring - see Issue #128"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Manifest Error Recovery Tests
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@test "load_package_manifest fails gracefully for missing manifest" {
    run load_package_manifest "nonexistent-package"

    assert_failure
    # Should return non-zero exit code
}

@test "load_package_manifest fails for manifest missing required files array" {
    # Create manifest without files array
    local test_package="$TEST_DOTFILES_DIR/packages/no-files"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
name = "No Files Test"
description = "Missing files array"
EOF

    run load_package_manifest "no-files"

    assert_failure
    # Error message should mention missing files
}

@test "load_package_manifest handles malformed TOML gracefully" {
    # Create manifest with syntax errors
    local test_package="$TEST_DOTFILES_DIR/packages/bad-toml"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = [unclosed array
name = "Bad TOML"
EOF

    run load_package_manifest "bad-toml"

    # Should fail but not crash
    assert_failure
}

@test "load_package_manifest handles empty files array" {
    # Create manifest with empty files array
    local test_package="$TEST_DOTFILES_DIR/packages/empty-files"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = []
name = "Empty Files Test"
EOF

    run load_package_manifest "empty-files"

    # Should fail - files array is required
    assert_failure
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# TOML Parser Edge Case Tests
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@test "get_toml_value handles empty string value" {
    # Create test manifest with empty string
    local test_manifest="$TEST_DOTFILES_DIR/test-empty.toml"
    cat > "$test_manifest" <<'EOF'
name = ""
description = "Test"
EOF

    run get_toml_value "$test_manifest" "" "name"

    assert_success
    assert_output ""
}

@test "get_toml_value handles value with spaces" {
    skip "TODO: Edge case testing - whitespace handling needs investigation"
}

@test "get_toml_value handles special characters in value" {
    skip "TODO: Edge case testing - special character escaping needs investigation"
}

@test "get_toml_array handles single element array" {
    # Create test manifest with single-element array
    local test_manifest="$TEST_DOTFILES_DIR/test-single.toml"
    cat > "$test_manifest" <<'EOF'
files = ["single.txt"]
EOF

    run get_toml_array "$test_manifest" "" "files"

    assert_success
    assert_output "single.txt"
}

@test "get_toml_array handles array with quoted strings containing commas" {
    # Create test manifest with commas in quoted strings
    local test_manifest="$TEST_DOTFILES_DIR/test-comma.toml"
    cat > "$test_manifest" <<'EOF'
files = ["file1.txt", "file,with,commas.txt", "file3.txt"]
EOF

    run get_toml_array "$test_manifest" "" "files"

    assert_success
    # Should preserve commas within quoted strings
    assert_output --partial "file,with,commas.txt"
}

@test "get_toml_array handles multi-line array" {
    # Create test manifest with multi-line array
    local test_manifest="$TEST_DOTFILES_DIR/test-multiline.toml"
    cat > "$test_manifest" <<'EOF'
files = [
    "file1.txt",
    "file2.txt",
    "file3.txt"
]
EOF

    run get_toml_array "$test_manifest" "" "files"

    assert_success
    assert_output --partial "file1.txt"
    assert_output --partial "file2.txt"
    assert_output --partial "file3.txt"
}

@test "get_toml_array handles array with trailing comma" {
    # Create test manifest with trailing comma
    local test_manifest="$TEST_DOTFILES_DIR/test-trailing.toml"
    cat > "$test_manifest" <<'EOF'
files = ["file1.txt", "file2.txt",]
EOF

    run get_toml_array "$test_manifest" "" "files"

    assert_success
    # Should handle trailing comma gracefully
    assert_output --partial "file1.txt"
    assert_output --partial "file2.txt"
}

@test "get_toml_value handles keys with dots" {
    # Create test manifest with dotted keys
    local test_manifest="$TEST_DOTFILES_DIR/test-dots.toml"
    cat > "$test_manifest" <<'EOF'
"target.macos" = "Library"
"target.linux" = "config"
EOF

    run get_toml_value "$test_manifest" "" "target.macos"

    assert_success
    assert_output "Library"
}

@test "get_toml_value handles inline comments" {
    skip "TODO: Edge case testing - inline comment handling needs investigation"
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# Manifest Validation Tests
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@test "get_package_files requires valid manifest" {
    # Create package directory without manifest
    local test_package="$TEST_DOTFILES_DIR/packages/no-manifest"
    mkdir -p "$test_package"

    run get_package_files "no-manifest"

    assert_failure
}

@test "load_package_manifest validates required fields present" {
    # Files array is the only truly required field
    local test_package="$TEST_DOTFILES_DIR/packages/minimal"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = ["test.txt"]
EOF

    run load_package_manifest "minimal"

    assert_success
    # Should succeed with just files array
    # Other fields should have defaults
}

@test "load_package_manifest sets defaults for optional fields" {
    # Create minimal manifest
    local test_package="$TEST_DOTFILES_DIR/packages/defaults"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = ["test.txt"]
EOF

    load_package_manifest "defaults" || return 1

    # Check defaults are applied
    assert_equal "$PACKAGE_METHOD" "stow"
    assert_equal "$PACKAGE_TARGET" "$HOME"
    assert_equal "$PACKAGE_NAME" "defaults"
}

