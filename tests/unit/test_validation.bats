#!/usr/bin/env bats
# Unit tests for validation functions

load ../test_helper/common

setup() {
    setup_test_dotfiles
    cd "$TEST_DOTFILES_DIR" || return 1
    source_dot_script
}

teardown() {
    teardown_test_dotfiles
}

@test "command_exists returns success for existing command" {
    run command_exists "bash"
    assert_success
}

@test "command_exists returns failure for non-existing command" {
    run command_exists "this-command-does-not-exist-12345"
    assert_failure
}

@test "count_orphaned_symlinks runs without crashing" {
    # Note: count_orphaned_symlinks checks $HOME for broken symlinks
    # Isolating HOME causes test execution issues in BATS
    # This test verifies the function runs without error
    run count_orphaned_symlinks
    assert_success
    # Output is a count (0 or more)
    assert_output --regexp "^[0-9]+$"
}

# Helper function to normalize validation output
# Normalize validation output for comparison in tests
# Removes whitespace, quotes, and brackets from TOML parser output
# Handles variations in TOML formatting (quotes, spacing, etc.)
# Output format: "command|arg1,arg2,arg3"
normalize_validation_output() {
    local output="$1"
    # Trim whitespace
    output=$(echo "$output" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
    # Extract command (before |)
    local cmd="${output%%|*}"
    cmd=$(echo "$cmd" | sed 's/^["'\'']//; s/["'\'']$//; s/^[[:space:]]*//; s/[[:space:]]*$//')
    # Extract args (after |)
    local args="${output#*|}"
    # Remove all brackets (handles nested cases)
    args=$(echo "$args" | sed 's/\[//g; s/\]//g')
    # Remove quotes
    args=$(echo "$args" | sed 's/["'\'']//g')
    # Remove all whitespace
    args=$(echo "$args" | tr -d '[:space:]')
    echo "$cmd|$args"
}

# Validation metadata function tests

@test "get_toml_inline_table extracts command and args correctly" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"

    # First verify function exists and runs
    run get_toml_inline_table "$manifest" "validation" ".gitconfig"
    assert_success

    # Normalize output for comparison
    local output
    output=$(get_toml_inline_table "$manifest" "validation" ".gitconfig")
    output=$(normalize_validation_output "$output")

    assert_equal "$output" "git|config,--list"
}

@test "get_toml_inline_table handles command without args" {
    # Create a test manifest with validator without args
    local test_manifest="$TEST_DOTFILES_DIR/test_manifest.toml"
    cat > "$test_manifest" <<EOF
[validation]
"test.txt" = { command = "cat" }
EOF

    # First verify function runs
    run get_toml_inline_table "$test_manifest" "validation" "test.txt"
    assert_success

    # Should return command with empty args
    local output
    output=$(get_toml_inline_table "$test_manifest" "validation" "test.txt")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "cat|"
}

@test "get_toml_inline_table handles multi-arg arrays" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"

    # First verify function runs
    run get_toml_inline_table "$manifest" "validation" ".gitconfig"
    assert_success

    # Verify args are comma-separated
    local output
    output=$(get_toml_inline_table "$manifest" "validation" ".gitconfig")
    output=$(normalize_validation_output "$output")
    local args="${output#*|}"

    assert_equal "$args" "config,--list"
}

@test "get_toml_inline_table returns failure for non-existent key" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"
    run get_toml_inline_table "$manifest" "validation" ".nonexistent"

    assert_failure
}

@test "get_toml_inline_table returns failure for non-existent section" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"
    run get_toml_inline_table "$manifest" "nonexistent" ".gitconfig"

    assert_failure
}

@test "get_toml_inline_table handles quoted keys" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"

    # First verify function runs
    run get_toml_inline_table "$manifest" "validation" ".gitconfig"
    assert_success

    # Should successfully extract regardless of quoted key
    local output
    output=$(get_toml_inline_table "$manifest" "validation" ".gitconfig")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "git|config,--list"
}

@test "get_validation_entry retrieves correct validator" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"

    # First verify function runs
    run get_validation_entry "$manifest" ".gitconfig"
    assert_success

    # Output format: "command|arg1,arg2,arg3" (may have whitespace)
    local output
    output=$(get_validation_entry "$manifest" ".gitconfig")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "git|config,--list"
}

@test "get_validation_entry returns failure for non-existent key" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"
    run get_validation_entry "$manifest" ".nonexistent"

    assert_failure
}

@test "get_validation_patterns extracts all patterns" {
    local manifest="$PACKAGES_DIR/git/manifest.toml"
    run get_validation_patterns "$manifest"

    assert_success
    assert_output ".gitconfig"
}

@test "get_validation_patterns extracts wildcard patterns" {
    local manifest="$PACKAGES_DIR/zsh/manifest.toml"
    run get_validation_patterns "$manifest"

    assert_success
    assert_output ".zshrc*"
}

@test "get_validation_patterns handles multiple patterns" {
    # Create a test manifest with multiple validation patterns
    local test_manifest="$TEST_DOTFILES_DIR/test_manifest.toml"
    cat > "$test_manifest" <<EOF
[validation]
"file1.txt" = { command = "cat", args = ["file"] }
"*.txt" = { command = "cat", args = ["file"] }
".config/file.json" = { command = "python3", args = ["-m", "json.tool", "file"] }
EOF

    run get_validation_patterns "$test_manifest"

    assert_success
    # Should return all three patterns (order may vary)
    assert_output --partial "file1.txt"
    assert_output --partial "*.txt"
    assert_output --partial ".config/file.json"
}

@test "get_validation_patterns returns empty for no validation section" {
    # Create a test manifest without validation section
    local test_manifest="$TEST_DOTFILES_DIR/test_manifest.toml"
    cat > "$test_manifest" <<EOF
files = ["test.txt"]
name = "Test"
EOF

    run get_validation_patterns "$test_manifest"

    assert_failure
}

@test "get_validator_for_file matches exact file path" {
    # First verify function runs
    run get_validator_for_file ".gitconfig" "git"
    assert_success

    # Output format: "command|arg1,arg2,arg3" (may have whitespace)
    local output
    output=$(get_validator_for_file ".gitconfig" "git")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "git|config,--list"
}

@test "get_validator_for_file matches wildcard pattern" {
    # First verify function runs
    run get_validator_for_file ".zshrc" "zsh"
    assert_success

    # Output format: "command|arg1,arg2,arg3" (may have whitespace)
    local output
    output=$(get_validator_for_file ".zshrc" "zsh")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "zsh|-n,file"
}

@test "get_validator_for_file matches wildcard pattern for .zprofile" {
    # First verify function runs
    run get_validator_for_file ".zprofile" "zsh"
    assert_success

    # Should match .zshrc* pattern
    # Output format: "command|arg1,arg2,arg3" (may have whitespace)
    local output
    output=$(get_validator_for_file ".zprofile" "zsh")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "zsh|-n,file"
}

@test "get_validator_for_file prefers exact match over wildcard" {
    # Create a test manifest with both exact and wildcard matches
    local test_manifest="$TEST_DOTFILES_DIR/packages/test/manifest.toml"
    mkdir -p "$TEST_DOTFILES_DIR/packages/test"
    cat > "$test_manifest" <<EOF
files = ["file.txt"]
name = "Test"
[validation]
"file.txt" = { command = "exact", args = ["match"] }
"*.txt" = { command = "wildcard", args = ["match"] }
EOF

    # First verify function runs
    run get_validator_for_file "file.txt" "test"
    assert_success

    # Should return exact match, not wildcard
    local output
    output=$(get_validator_for_file "file.txt" "test")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "exact|match"
}

@test "get_validator_for_file returns failure for no match" {
    run get_validator_for_file ".nonexistent" "git"

    assert_failure
}

@test "get_validator_for_file returns failure for non-existent package" {
    run get_validator_for_file ".gitconfig" "nonexistent"

    assert_failure
}

@test "run_validator executes command successfully" {
    # Test with a simple command that always succeeds
    run run_validator "true"

    assert_success
}

@test "run_validator handles missing command gracefully" {
    run run_validator "this-command-does-not-exist-12345" "arg1"

    assert_success  # Should continue, not fail
    # Should output warning (check stderr)
}

@test "run_validator replaces 'file' placeholder in args" {
    # Create a test file
    local test_file="$TEST_DOTFILES_DIR/test_file.txt"
    echo "test content" > "$test_file"

    # Test validator that checks file exists
    run run_validator "test" "-f" "file"

    # Since 'test' is a shell builtin, it won't work as a command
    # But we can test the replacement logic with a command that accepts file path
    if command_exists "cat"; then
        run run_validator "cat" "file"
        assert_success
    fi
}

@test "run_validator handles tmux validation with cleanup" {
    # Skip if tmux not available
    if ! command_exists "tmux"; then
        skip "tmux not available"
    fi

    # Test tmux validation using dev/validate-tmux script
    local test_file="$TEST_DOTFILES_DIR/test_tmux.conf"
    echo "set -g default-terminal \"screen-256color\"" > "$test_file"

    run run_validator "dev/validate-tmux" "$test_file"

    # Should clean up test session
    # Verify no test session remains
    run tmux list-sessions 2>/dev/null || true
    refute_output --partial "dotfiles-config-test"
}

@test "run_validator preserves spaces in arguments" {
    # Test that arguments with spaces are preserved correctly
    if command_exists "echo"; then
        run run_validator "echo" "arg with spaces"

        assert_success
        assert_output "arg with spaces"
    fi
}

@test "get_toml_inline_table handles array with single element" {
    local test_manifest="$TEST_DOTFILES_DIR/test_manifest.toml"
    cat > "$test_manifest" <<EOF
[validation]
"test.txt" = { command = "cat", args = ["single"] }
EOF

    # First verify function runs
    run get_toml_inline_table "$test_manifest" "validation" "test.txt"
    assert_success

    local output
    output=$(get_toml_inline_table "$test_manifest" "validation" "test.txt")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "cat|single"
}

@test "get_toml_inline_table handles array with multiple elements" {
    local test_manifest="$TEST_DOTFILES_DIR/test_manifest.toml"
    cat > "$test_manifest" <<EOF
[validation]
"test.txt" = { command = "cmd", args = ["arg1", "arg2", "arg3"] }
EOF

    # First verify function runs
    run get_toml_inline_table "$test_manifest" "validation" "test.txt"
    assert_success

    local output
    output=$(get_toml_inline_table "$test_manifest" "validation" "test.txt")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "cmd|arg1,arg2,arg3"
}

@test "get_toml_inline_table handles quotes in array elements" {
    local test_manifest="$TEST_DOTFILES_DIR/test_manifest.toml"
    cat > "$test_manifest" <<EOF
[validation]
"test.txt" = { command = "cmd", args = ["arg with spaces", "normal"] }
EOF

    # First verify function runs
    run get_toml_inline_table "$test_manifest" "validation" "test.txt"
    assert_success

    # Verify quotes are stripped
    local output
    output=$(get_toml_inline_table "$test_manifest" "validation" "test.txt")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "cmd|arg with spaces,normal"
}

@test "get_toml_inline_table handles empty args array" {
    local test_manifest="$TEST_DOTFILES_DIR/test_manifest.toml"
    cat > "$test_manifest" <<EOF
[validation]
"test.txt" = { command = "cmd", args = [] }
EOF

    # First verify function runs
    run get_toml_inline_table "$test_manifest" "validation" "test.txt"
    assert_success

    # Should return command with empty args
    local output
    output=$(get_toml_inline_table "$test_manifest" "validation" "test.txt")
    output=$(normalize_validation_output "$output")
    assert_equal "$output" "cmd|"
}
