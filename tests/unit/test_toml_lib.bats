#!/usr/bin/env bats
# Unit tests for lib/toml.sh

load ../test_helper/common

setup() {
    # Source lib/toml.sh (includes common.sh and output.sh dependencies)
    source_lib_toml

    # Create temporary test manifest file
    TEST_MANIFEST="$(mktemp)"
    cat > "$TEST_MANIFEST" << 'EOF'
name = "Test Package"
description = "Test package description"
method = "stow"
target = "~"

files = [
    ".config/app/config",
    ".config/app/settings.json"
]

[validation]
".config/app/config" = { command = "validate-config", args = ["--check"] }
"*.json" = { command = "python3", args = ["-m", "json.tool", "file"] }

[update]
command = "dev/update-script"
args = ["file"]
EOF

    # Create test manifest with sections
    TEST_MANIFEST_SECTIONS="$(mktemp)"
    cat > "$TEST_MANIFEST_SECTIONS" << 'EOF'
key1 = "value1"
key2 = "value2"

[section1]
key3 = "value3"
key4 = "value4"

[section2]
key5 = "value5"
EOF

    # Create test manifest with arrays
    TEST_MANIFEST_ARRAYS="$(mktemp)"
    cat > "$TEST_MANIFEST_ARRAYS" << 'EOF'
simple_array = ["item1", "item2", "item3"]
multiline_array = [
    "line1",
    "line2",
    "line3"
]
nested_content = "test"
EOF
}

teardown() {
    # Clean up test files
    [[ -f "$TEST_MANIFEST" ]] && rm -f "$TEST_MANIFEST"
    [[ -f "$TEST_MANIFEST_SECTIONS" ]] && rm -f "$TEST_MANIFEST_SECTIONS"
    [[ -f "$TEST_MANIFEST_ARRAYS" ]] && rm -f "$TEST_MANIFEST_ARRAYS"
}

@test "trim_quotes_and_whitespace removes quotes" {
    run trim_quotes_and_whitespace '"quoted"'
    assert_success
    assert_output "quoted"

    run trim_quotes_and_whitespace "'quoted'"
    assert_success
    assert_output "quoted"
}

@test "trim_quotes_and_whitespace removes whitespace" {
    run trim_quotes_and_whitespace "  spaced  "
    assert_success
    assert_output "spaced"
}

@test "trim_quotes_and_whitespace removes quotes and whitespace" {
    run trim_quotes_and_whitespace '  "quoted with spaces"  '
    assert_success
    assert_output "quoted with spaces"
}

@test "escape_regex_special_chars escapes brackets" {
    run escape_regex_special_chars "[section]"
    assert_success
    assert_output "\\[section\\]"
}

@test "escape_regex_special_chars escapes dots" {
    run escape_regex_special_chars "file.name"
    assert_success
    assert_output "file\\.name"
}

@test "get_toml_value retrieves top-level value" {
    run get_toml_value "$TEST_MANIFEST" "" "name"
    assert_success
    assert_output "Test Package"
}

@test "get_toml_value retrieves section value" {
    run get_toml_value "$TEST_MANIFEST_SECTIONS" "section1" "key3"
    assert_success
    assert_output "value3"
}

@test "get_toml_value handles quoted values" {
    run get_toml_value "$TEST_MANIFEST" "" "name"
    assert_success
    # Should remove quotes from "Test Package"
    assert_output "Test Package"
}

@test "get_toml_value returns failure for missing key" {
    run get_toml_value "$TEST_MANIFEST" "" "nonexistent"
    assert_failure
}

@test "get_toml_value returns failure for missing section" {
    run get_toml_value "$TEST_MANIFEST" "nonexistent" "key"
    assert_failure
}

@test "get_toml_value returns failure for missing file" {
    run get_toml_value "/nonexistent/file.toml" "" "key"
    assert_failure
}

@test "get_toml_array retrieves simple array" {
    run get_toml_array "$TEST_MANIFEST_ARRAYS" "" "simple_array"
    assert_success
    # Should return comma-separated values
    assert_output --partial "item1"
    assert_output --partial "item2"
    assert_output --partial "item3"
}

@test "get_toml_array retrieves multiline array" {
    run get_toml_array "$TEST_MANIFEST_ARRAYS" "" "multiline_array"
    assert_success
    assert_output --partial "line1"
    assert_output --partial "line2"
    assert_output --partial "line3"
}

@test "get_toml_array returns failure for missing key" {
    run get_toml_array "$TEST_MANIFEST_ARRAYS" "" "nonexistent"
    assert_failure
}

@test "get_toml_array returns failure for missing file" {
    run get_toml_array "/nonexistent/file.toml" "" "key"
    assert_failure
}

@test "get_toml_inline_table extracts command and args" {
    run get_toml_inline_table "$TEST_MANIFEST" "validation" ".config/app/config"
    assert_success
    # Should return format: "command|arg1,arg2"
    assert_output --partial "validate-config"
    assert_output --partial "|"
    assert_output --partial "--check"
}

@test "get_toml_inline_table handles command without args" {
    # Create a manifest with command but no args
    local test_file
    test_file="$(mktemp)"
    cat > "$test_file" << 'EOF'
[test]
"key" = { command = "cmd" }
EOF

    run get_toml_inline_table "$test_file" "test" "key"
    assert_success
    assert_output --partial "cmd"
    assert_output --partial "|"

    rm -f "$test_file"
}

@test "get_toml_inline_table returns failure for missing key" {
    run get_toml_inline_table "$TEST_MANIFEST" "validation" "nonexistent"
    assert_failure
}

@test "get_toml_inline_table returns failure for missing section" {
    run get_toml_inline_table "$TEST_MANIFEST" "nonexistent" "key"
    assert_failure
}

@test "apply_platform_target_override applies linux target" {
    # Create manifest with platform override
    local test_file
    test_file="$(mktemp)"
    cat > "$test_file" << 'EOF'
target = "~/.config/app"

[linux]
target = "~/.local/share/app"
EOF

    # Set platform to linux and test
    local original_platform="${OSTYPE:-}"
    export OSTYPE="linux-gnu"

    # Initialize PACKAGE_TARGET
    PACKAGE_TARGET="$HOME/.config/app"

    apply_platform_target_override "$test_file" "linux"

    # Should have updated PACKAGE_TARGET
    [[ "$PACKAGE_TARGET" == *".local/share/app" ]] || fail "Should override with linux target"

    export OSTYPE="$original_platform"
    rm -f "$test_file"
}

@test "apply_platform_target_override applies macos target" {
    # Create manifest with platform override
    local test_file
    test_file="$(mktemp)"
    cat > "$test_file" << 'EOF'
target = "~/.config/app"

[macos]
target = "~/Library/Application Support/app"
EOF

    # Set platform to macos and test
    local original_platform="${OSTYPE:-}"
    export OSTYPE="darwin"

    # Initialize PACKAGE_TARGET
    PACKAGE_TARGET="$HOME/.config/app"

    apply_platform_target_override "$test_file" "macos"

    # Should have updated PACKAGE_TARGET
    [[ "$PACKAGE_TARGET" == *"Library/Application Support/app" ]] || fail "Should override with macos target"

    export OSTYPE="$original_platform"
    rm -f "$test_file"
}

@test "apply_platform_target_override does nothing for unknown platform" {
    local test_file
    test_file="$(mktemp)"
    cat > "$test_file" << 'EOF'
target = "~/.config/app"
EOF

    PACKAGE_TARGET="$HOME/.config/app"
    local original_target="$PACKAGE_TARGET"

    apply_platform_target_override "$test_file" "unknown"

    # Should remain unchanged
    [[ "$PACKAGE_TARGET" == "$original_target" ]] || fail "Should not change for unknown platform"

    rm -f "$test_file"
}

