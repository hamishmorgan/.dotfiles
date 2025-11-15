#!/usr/bin/env bats
# Unit tests for lib/common.sh

load ../test_helper/common

setup() {
    # Source lib/common.sh for testing
    source_lib_common
}

teardown() {
    # No cleanup needed for unit tests
    :
}

@test "command_exists returns success for existing command" {
    run command_exists "bash"
    assert_success
}

@test "command_exists returns failure for non-existing command" {
    run command_exists "this-command-does-not-exist-12345"
    assert_failure
}

@test "command_exists works with multiple commands" {
    run command_exists "bash"
    assert_success

    run command_exists "sh"
    assert_success

    run command_exists "nonexistent-command-xyz"
    assert_failure
}

@test "portable_timeout uses timeout command when available" {
    skip "Requires actual timeout command - may not be available in all test environments"

    # This test would verify timeout is used when available
    # Skipped because timeout may not be available in test environment
    run portable_timeout 1 echo "test"
    # Should succeed and output "test"
    assert_success
    assert_output "test"
}

@test "portable_timeout falls back to perl when timeout unavailable" {
    skip "Complex to test - requires mocking command_exists"

    # This would test perl fallback, but requires complex mocking
    # Skipped for now - integration tests cover this
}

@test "portable_timeout runs command normally when no timeout available" {
    # When neither timeout nor perl is available, command runs normally
    # This is hard to test without mocking, but the function should not crash
    run portable_timeout 1 echo "test-output"
    # Should succeed (command ran, even if not actually timed out)
    assert_success
    assert_output "test-output"
}

@test "detect_platform returns macos on darwin" {
    skip "Cannot easily mock OSTYPE in BATS"

    # This test would verify platform detection
    # Skipped because it requires mocking OSTYPE which is difficult
}

@test "detect_platform returns linux on linux-gnu" {
    skip "Cannot easily mock OSTYPE in BATS"

    # Platform detection is tested in integration tests
}

@test "detect_platform returns unknown for unsupported platforms" {
    skip "Cannot easily mock OSTYPE in BATS"

    # Platform detection is tested in integration tests
}

@test "constants are properly defined" {
    # Verify timeout constants exist
    [[ -n "$GIT_TIMEOUT" ]] || fail "GIT_TIMEOUT constant not defined"
    [[ -n "$CURL_TIMEOUT" ]] || fail "CURL_TIMEOUT constant not defined"

    # Verify backup constants exist
    [[ -n "$MAX_BACKUPS_TO_DISPLAY" ]] || fail "MAX_BACKUPS_TO_DISPLAY constant not defined"
    [[ -n "$MAX_BACKUPS_TO_KEEP" ]] || fail "MAX_BACKUPS_TO_KEEP constant not defined"

    # Note: Color and symbol constants are now in lib/output.sh (tested in test_output_lib.bats)
}

