#!/usr/bin/env bats
# Integration tests for manifest requirement enforcement

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "Package without manifest is not discovered" {
    # Create package directory without manifest
    local test_package="$TEST_DOTFILES_DIR/packages/no-manifest-pkg"
    mkdir -p "$test_package"
    echo "test content" > "$test_package/test.txt"

    # Discover packages
    run discover_packages

    # Package without manifest should NOT be in list
    refute_output --partial "no-manifest-pkg"
}

@test "initialize_packages fails with helpful error for missing manifest" {
    # Create package with manifest, then remove it
    local test_package="$TEST_DOTFILES_DIR/packages/broken-pkg"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = ["test.txt"]
name = "Broken"
EOF

    # First verify it's discovered
    local discovered
    discovered=$(discover_packages)
    assert [[ "$discovered" == *"broken-pkg"* ]]

    # Now remove the manifest and try to initialize
    rm "$test_package/manifest.toml"

    # Initialize should fail because manifest is missing
    run initialize_packages

    assert_failure
    assert_output --partial "missing manifest"
}

@test "initialize_packages validates manifest can be parsed" {
    # Create package with malformed manifest
    local test_package="$TEST_DOTFILES_DIR/packages/bad-toml-pkg"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = [unclosed
name = "Bad"
EOF

    run initialize_packages

    assert_failure
    assert_output --partial "invalid manifest"
}

@test "validate_all_manifests detects missing manifest" {
    # Manually populate PACKAGES with a non-existent package
    PACKAGES=("system" "nonexistent")

    run validate_all_manifests

    assert_failure
    assert_output --partial "missing required manifest"
    assert_output --partial "nonexistent"
}

@test "validate_all_manifests detects unreadable manifest" {
    # Create manifest and make it unreadable
    local test_package="$TEST_DOTFILES_DIR/packages/unreadable"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
files = ["test.txt"]
name = "Unreadable"
EOF
    chmod 000 "$test_package/manifest.toml"

    # Add to PACKAGES array
    PACKAGES=("unreadable")

    run validate_all_manifests

    assert_failure
    assert_output --partial "not readable"

    # Cleanup
    chmod 644 "$test_package/manifest.toml"
}

@test "validate_all_manifests detects missing files array" {
    # Create manifest without files array
    local test_package="$TEST_DOTFILES_DIR/packages/no-files-pkg"
    mkdir -p "$test_package"
    cat > "$test_package/manifest.toml" <<'EOF'
name = "No Files"
description = "Missing files array"
EOF

    PACKAGES=("no-files-pkg")

    run validate_all_manifests

    assert_failure
    assert_output --partial "invalid manifest"
}

@test "validate_all_manifests succeeds for valid manifests" {
    # Use real packages from test setup (system, git, etc.)
    run validate_all_manifests

    assert_success
}

@test "get_package_files fails immediately without manifest" {
    # Package without manifest should fail fast
    run get_package_files "nonexistent-package"

    assert_failure
}

@test "Package operations require valid manifests" {
    # Create package directory without manifest
    local test_package="$PACKAGES_DIR/test-no-manifest"
    mkdir -p "$test_package"

    # Try to use package - should fail
    run get_package_files "test-no-manifest"

    assert_failure
    assert_output --partial "missing manifest"

    # Cleanup
    rm -rf "$test_package"
}

