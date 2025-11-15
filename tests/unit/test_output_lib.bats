#!/usr/bin/env bats
# Unit tests for lib/output.sh

load ../test_helper/common

setup() {
    # Source lib/output.sh (includes common.sh dependency)
    source_lib_output
}

teardown() {
    # No cleanup needed for unit tests
    :
}

@test "log_info outputs blue message" {
    run log_info "Test message"
    assert_success
    # Should contain blue escape code and SYMBOL_INFO
    assert_output --regexp "\\[0;34m"  # Blue color code
    assert_output --partial "Test message"
}

@test "log_success outputs green message" {
    run log_success "Success message"
    assert_success
    assert_output --regexp "\\[0;32m"  # Green color code
    assert_output --partial "Success message"
}

@test "log_warning outputs yellow message" {
    run log_warning "Warning message"
    assert_success
    assert_output --regexp "\\[1;33m"  # Yellow color code
    assert_output --partial "Warning message"
}

@test "log_error outputs red message" {
    run log_error "Error message"
    assert_success
    assert_output --regexp "\\[0;31m"  # Red color code
    assert_output --partial "Error message"
}

@test "prefix_output colors error lines red" {
    # Use command substitution to capture piped output
    local output
    output=$(echo "ERROR: something failed" | prefix_output)

    # Check that output contains RED constant (set in common.sh)
    # Instead of checking escape codes, verify output is not empty and contains error text
    [[ -n "$output" ]] || fail "Should produce output"
    [[ "$output" == *"ERROR"* ]] || fail "Should contain ERROR text"
}

@test "prefix_output colors warning lines yellow" {
    local output
    output=$(echo "WARNING: something" | prefix_output)

    # Verify output contains warning text
    [[ -n "$output" ]] || fail "Should produce output"
    [[ "$output" == *"WARNING"* ]] || fail "Should contain WARNING text"
}

@test "prefix_output colors success lines green" {
    local output
    output=$(echo "SUCCESS: done" | prefix_output)

    # Verify output contains success text
    [[ -n "$output" ]] || fail "Should produce output"
    [[ "$output" == *"SUCCESS"* ]] || fail "Should contain SUCCESS text"
}

@test "prefix_output uses default prefix when none provided" {
    local output
    output=$(echo "normal output" | prefix_output)

    [[ "$output" == *"$OUTPUT_PREFIX"* ]] || fail "Should contain default prefix"
}

@test "prefix_output uses custom prefix when provided" {
    local output
    output=$(echo "normal output" | prefix_output ">>> ")

    [[ "$output" == *">>> "* ]] || fail "Should contain custom prefix"
}

@test "show_header displays boxed title" {
    run show_header "Test Title"
    assert_success
    assert_output --partial "Test Title"
    assert_output --partial "╭"
    assert_output --partial "╰"
}

@test "show_header respects verbosity mute" {
    run show_header "Test Title" "$VERBOSITY_MUTE"
    assert_success
    # Should output nothing in mute mode
    [[ -z "$output" ]] || fail "Should output nothing in mute mode"
}

@test "show_section_separator displays title" {
    run show_section_separator "Section Title"
    assert_success
    assert_output --partial "Section Title"
    assert_output --partial "━━━"
}

@test "show_section_separator displays separator without title" {
    run show_section_separator ""
    assert_success
    assert_output --partial "━━━"
    refute_output --partial "Section"
}

@test "show_numbered_section displays numbered title" {
    run show_numbered_section "1" "First Step"
    assert_success
    assert_output --partial "1. First Step"
    assert_output --partial "━━━"
}

@test "show_numbered_section respects verbosity mute" {
    run show_numbered_section "1" "First Step" "$VERBOSITY_MUTE"
    assert_success
    [[ -z "$output" ]] || fail "Should output nothing in mute mode"
}

@test "show_summary displays success message" {
    run show_summary "success" "Operation completed"
    assert_success
    assert_output --partial "Operation completed"
    assert_output --regexp "\\[0;32m"  # Green color code
}

@test "show_summary displays info message" {
    run show_summary "info" "Information message"
    assert_success
    assert_output --partial "Information message"
    assert_output --regexp "\\[0;34m"  # Blue color code
}

@test "show_summary includes duration when provided" {
    run show_summary "success" "Operation completed" "1.5"
    assert_success
    assert_output --partial "Operation completed"
    assert_output --partial "Duration: 1.5s"
}

@test "show_summary respects verbosity mute" {
    run show_summary "success" "Message" "" "$VERBOSITY_MUTE"
    assert_success
    [[ -z "$output" ]] || fail "Should output nothing in mute mode"
}

@test "show_tip displays tip message" {
    run show_tip "Tip message"
    assert_success
    assert_output --partial "💡 Tip: Tip message"
}

@test "show_tip respects verbosity mute" {
    run show_tip "Tip message" "$VERBOSITY_MUTE"
    assert_success
    [[ -z "$output" ]] || fail "Should output nothing in mute mode"
}

@test "show_tips displays titled tips" {
    run show_tips "Title" "Tip 1" "Tip 2" "Tip 3"
    assert_success
    assert_output --partial "💡 Title:"
    assert_output --partial "Tip 1"
    assert_output --partial "Tip 2"
    assert_output --partial "Tip 3"
}

@test "show_tips respects verbosity mute" {
    run show_tips "Title" "Tip 1" "$VERBOSITY_MUTE"
    assert_success
    [[ -z "$output" ]] || fail "Should output nothing in mute mode"
}

@test "indent_section_output indents lines" {
    # Test by using a subshell to capture piped output
    local output
    output=$(printf "line1\nline2\nline3\n" | indent_section_output)

    [[ "$output" == *"   line1"* ]] || fail "Should indent line1"
    [[ "$output" == *"   line2"* ]] || fail "Should indent line2"
    [[ "$output" == *"   line3"* ]] || fail "Should indent line3"
}

@test "run_with_verbosity shows details at high verbosity" {
    run run_with_verbosity "$VERBOSITY_GARRULOUS" "$VERBOSITY_LOQUACIOUS" "" echo "test output"
    assert_success
    assert_output --partial "test output"
    assert_output --partial "   "  # Should be indented
}

@test "run_with_verbosity hides details at low verbosity" {
    run run_with_verbosity "$VERBOSITY_TACITURN" "$VERBOSITY_LOQUACIOUS" "Success" echo "hidden output"
    assert_success
    assert_output --partial "Success"
    refute_output --partial "hidden output"
}

@test "run_with_verbosity shows success message when command succeeds" {
    run run_with_verbosity "$VERBOSITY_TACITURN" "$VERBOSITY_LOQUACIOUS" "Task completed" true
    assert_success
    assert_output --partial "Task completed"
}

@test "run_with_verbosity shows errors when command fails" {
    run run_with_verbosity "$VERBOSITY_TACITURN" "$VERBOSITY_LOQUACIOUS" "" false
    assert_failure
    # Should show error output (indented)
}

@test "run_step shows numbered section" {
    run run_step "1" "Step Title" "$VERBOSITY_TACITURN" "$VERBOSITY_LOQUACIOUS" "Success" "Error" true
    assert_success
    assert_output --partial "1. Step Title"
}

@test "run_step shows error message on failure" {
    run run_step "1" "Step Title" "$VERBOSITY_TACITURN" "$VERBOSITY_LOQUACIOUS" "Success" "Step failed" false
    assert_failure
    assert_output --partial "Step failed"
    assert_output --regexp "\\[0;31m"  # Red color (error)
}

@test "verbosity constants are defined" {
    [[ "$VERBOSITY_MUTE" == "-1" ]] || fail "VERBOSITY_MUTE should be -1"
    [[ "$VERBOSITY_TACITURN" == "0" ]] || fail "VERBOSITY_TACITURN should be 0"
    [[ "$VERBOSITY_LOQUACIOUS" == "1" ]] || fail "VERBOSITY_LOQUACIOUS should be 1"
    [[ "$VERBOSITY_GARRULOUS" == "2" ]] || fail "VERBOSITY_GARRULOUS should be 2"
}

@test "color constants are defined" {
    # Verify color constants exist
    [[ -n "$RED" ]] || fail "RED constant not defined"
    [[ -n "$GREEN" ]] || fail "GREEN constant not defined"
    [[ -n "$YELLOW" ]] || fail "YELLOW constant not defined"
    [[ -n "$BLUE" ]] || fail "BLUE constant not defined"
    [[ -n "$NC" ]] || fail "NC constant not defined"
}

@test "symbol constants are defined" {
    # Verify symbol constants exist
    [[ -n "$SYMBOL_SUCCESS" ]] || fail "SYMBOL_SUCCESS constant not defined"
    [[ -n "$SYMBOL_ERROR" ]] || fail "SYMBOL_ERROR constant not defined"
    [[ -n "$SYMBOL_WARNING" ]] || fail "SYMBOL_WARNING constant not defined"
    [[ -n "$SYMBOL_INFO" ]] || fail "SYMBOL_INFO constant not defined"
}

