# Common test helper functions
# Load this in your test files with: load test_helper/common

# Load bats support libraries
load bats-support/load
load bats-assert/load

# Create a temporary dotfiles directory for testing
# Usage: setup_test_dotfiles
# Sets: TEST_DOTFILES_DIR, DOTFILES_DIR (exported)
setup_test_dotfiles() {
    export TEST_DOTFILES_DIR="$(mktemp -d)"
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"
    
    # Create basic structure
    mkdir -p "$TEST_DOTFILES_DIR"/{backups,system,git,zsh,tmux,gh,gnuplot,bash,fish}
    mkdir -p "$TEST_DOTFILES_DIR/tests"
    
    # Copy dot script
    cp "$BATS_TEST_DIRNAME/../dot" "$TEST_DOTFILES_DIR/"
}

# Clean up test dotfiles directory
# Usage: teardown_test_dotfiles
teardown_test_dotfiles() {
    if [[ -n "${TEST_DOTFILES_DIR:-}" && -d "$TEST_DOTFILES_DIR" ]]; then
        rm -rf "$TEST_DOTFILES_DIR"
    fi
}

# Create mock backup directories
# Usage: create_mock_backups COUNT SIZE_MB
# Example: create_mock_backups 15 1
create_mock_backups() {
    local count="$1"
    local size_mb="${2:-1}"
    local backup_dir="${DOTFILES_DIR:-$TEST_DOTFILES_DIR}/backups"
    
    mkdir -p "$backup_dir"
    
    for i in $(seq 1 "$count"); do
        local backup="$backup_dir/dotfiles-backup-$i"
        mkdir -p "$backup"
        dd if=/dev/zero of="$backup/file" bs=1M count="$size_mb" 2>/dev/null
    done
}

# Source the dot script functions for testing
# Usage: source_dot_script
source_dot_script() {
    local dot_script="${DOTFILES_DIR:-$TEST_DOTFILES_DIR}/dot"
    
    if [[ ! -f "$dot_script" ]]; then
        dot_script="$BATS_TEST_DIRNAME/../dot"
    fi
    
    # Source the script to get access to functions
    # Suppress main execution
    export BATS_TESTING=1
    source "$dot_script"
}

# Assert output contains a pattern
# Usage: assert_output_contains "pattern"
assert_output_contains() {
    local pattern="$1"
    if [[ ! "$output" =~ $pattern ]]; then
        echo "Expected output to contain: $pattern"
        echo "Actual output: $output"
        return 1
    fi
}

# Assert output does not contain a pattern  
# Usage: assert_output_not_contains "pattern"
assert_output_not_contains() {
    local pattern="$1"
    if [[ "$output" =~ $pattern ]]; then
        echo "Expected output to NOT contain: $pattern"
        echo "Actual output: $output"
        return 1
    fi
}

# Assert numeric value is in range
# Usage: assert_in_range VALUE MIN MAX
assert_in_range() {
    local value="$1"
    local min="$2"
    local max="$3"
    
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "Value is not numeric: $value"
        return 1
    fi
    
    if [ "$value" -lt "$min" ] || [ "$value" -gt "$max" ]; then
        echo "Expected $value to be between $min and $max"
        return 1
    fi
}

# Assert string is numeric
# Usage: assert_numeric "string"
assert_numeric() {
    local value="$1"
    if ! [[ "$value" =~ ^[0-9]+$ ]]; then
        echo "Expected numeric value, got: $value"
        return 1
    fi
}

# Get actual backup count in directory
# Usage: actual_backup_count=$(get_actual_backup_count)
get_actual_backup_count() {
    local backup_dir="${DOTFILES_DIR:-$TEST_DOTFILES_DIR}/backups"
    find "$backup_dir" -maxdepth 1 -type d -name "dotfiles-backup-*" 2>/dev/null | wc -l
}

# Get actual backup size in KB
# Usage: actual_size=$(get_actual_backup_size)
get_actual_backup_size() {
    local backup_dir="${DOTFILES_DIR:-$TEST_DOTFILES_DIR}/backups"
    local total=0
    
    while IFS= read -r dir; do
        [[ -z "$dir" ]] && continue
        local size
        size=$(du -sk "$dir" 2>/dev/null | cut -f1)
        ((total += size))
    done < <(find "$backup_dir" -maxdepth 1 -type d -name "dotfiles-backup-*" 2>/dev/null)
    
    echo "$total"
}

