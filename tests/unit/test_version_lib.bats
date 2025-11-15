#!/usr/bin/env bats
# Unit tests for lib/version.sh

load ../test_helper/common

setup() {
    # Source lib/version.sh (includes common.sh dependency)
    source_lib_version
}

teardown() {
    # No cleanup needed for unit tests
    :
}

@test "get_min_version returns version for git" {
    run get_min_version "git"
    assert_success
    assert_output "2.0.0"
}

@test "get_min_version returns version for stow" {
    run get_min_version "stow"
    assert_success
    assert_output "2.3"
}

@test "get_min_version returns empty for unknown tool" {
    run get_min_version "unknown-tool"
    assert_success
    assert_output ""
}

@test "version_ge returns success when v1 >= v2" {
    run version_ge "2.0.0" "1.0.0"
    assert_success

    run version_ge "1.5.0" "1.0.0"
    assert_success

    run version_ge "1.0.1" "1.0.0"
    assert_success
}

@test "version_ge returns failure when v1 < v2" {
    run version_ge "1.0.0" "2.0.0"
    assert_failure

    run version_ge "1.0.0" "1.5.0"
    assert_failure

    run version_ge "1.0.0" "1.0.1"
    assert_failure
}

@test "version_ge returns success for equal versions" {
    run version_ge "1.0.0" "1.0.0"
    assert_success

    run version_ge "2.3.0" "2.3.0"
    assert_success
}

@test "version_ge handles multi-part versions" {
    run version_ge "1.2.3" "1.2.2"
    assert_success

    run version_ge "1.2.3" "1.2.4"
    assert_failure

    run version_ge "2.0.0" "1.9.9"
    assert_success
}

@test "version_ge handles different length versions" {
    run version_ge "2.0" "1.9.9"
    assert_success

    run version_ge "1.9.9" "2.0"
    assert_failure

    run version_ge "2.0.0" "2.0"
    assert_success
}

@test "_version_ge_fallback works for equal versions" {
    run _version_ge_fallback "1.0.0" "1.0.0"
    assert_success
}

@test "_version_ge_fallback works for different versions" {
    run _version_ge_fallback "2.0.0" "1.0.0"
    assert_success

    run _version_ge_fallback "1.0.0" "2.0.0"
    assert_failure
}

@test "_version_ge_fallback handles version suffixes" {
    # Should strip letters and compare numerically
    run _version_ge_fallback "2.3a" "2.3"
    assert_success

    run _version_ge_fallback "2.3" "2.3a"
    assert_success  # Equal after stripping
}

@test "check_tool_version returns version for git when available" {
    skip "Requires git to be installed in test environment"

    run check_tool_version "git" "1.0.0"
    # Should succeed if git version >= 1.0.0, or fail if can't determine
    # We can't assert success/failure without knowing git version
    # But should at least not crash
}

@test "check_tool_version returns version for stow when available" {
    skip "Requires stow to be installed in test environment"

    run check_tool_version "stow" "1.0.0"
    # Should succeed if stow version >= 1.0.0
}

@test "check_tool_version fails for unknown tool" {
    run check_tool_version "unknown-tool-xyz" "1.0.0"
    assert_failure
    assert_output ""
}

@test "check_tool_version outputs version on stdout" {
    skip "Requires git to be installed in test environment"

    local version
    version=$(check_tool_version "git" "1.0.0" 2>/dev/null || echo "")
    # If git is available, should output version string
    if command_exists git; then
        [[ -n "$version" ]] || fail "Should output version when tool is available"
        # Version should match pattern
        [[ "$version" =~ ^[0-9]+\.[0-9]+ ]] || fail "Version should match pattern"
    fi
}

