# Common test helper functions
# Load this in your test files with: load ../test_helper/common

# Load BATS helper libraries
# These should be installed system-wide:
# macOS: brew install bats-core && brew tap bats-core/bats-core && brew install bats-support bats-assert bats-file
# Ubuntu: sudo apt-get install bats bats-assert bats-support bats-file

# Determine brew prefix on macOS (if applicable)
if command -v brew &>/dev/null; then
    BREW_PREFIX="$(brew --prefix 2>/dev/null || echo "/usr/local")"
else
    BREW_PREFIX="/usr/local"
fi

# Try to load bats-support from various locations
if [[ -f "/usr/lib/bats/bats-support/load.bash" ]]; then
    load "/usr/lib/bats/bats-support/load"
elif [[ -f "$BREW_PREFIX/lib/bats-support/load.bash" ]]; then
    load "$BREW_PREFIX/lib/bats-support/load"
elif [[ -f "/usr/local/lib/bats-support/load.bash" ]]; then
    load "/usr/local/lib/bats-support/load"
fi

# Try to load bats-assert
if [[ -f "/usr/lib/bats/bats-assert/load.bash" ]]; then
    load "/usr/lib/bats/bats-assert/load"
elif [[ -f "$BREW_PREFIX/lib/bats-assert/load.bash" ]]; then
    load "$BREW_PREFIX/lib/bats-assert/load"
elif [[ -f "/usr/local/lib/bats-assert/load.bash" ]]; then
    load "/usr/local/lib/bats-assert/load"
fi

# Try to load bats-file
if [[ -f "/usr/lib/bats/bats-file/load.bash" ]]; then
    load "/usr/lib/bats/bats-file/load"
elif [[ -f "$BREW_PREFIX/lib/bats-file/load.bash" ]]; then
    load "$BREW_PREFIX/lib/bats-file/load"
elif [[ -f "/usr/local/lib/bats-file/load.bash" ]]; then
    load "/usr/local/lib/bats-file/load"
fi

# Create a temporary dotfiles directory for testing
# Usage: setup_test_dotfiles
# Sets: TEST_DOTFILES_DIR, DOTFILES_DIR (exported)
setup_test_dotfiles() {
    export TEST_DOTFILES_DIR="$(mktemp -d)"
    export DOTFILES_DIR="$TEST_DOTFILES_DIR"

    # Create basic structure
    mkdir -p "$TEST_DOTFILES_DIR"/backups
    mkdir -p "$TEST_DOTFILES_DIR"/packages/{system,git,zsh,tmux,gh,gnuplot,bash,fish}
    mkdir -p "$TEST_DOTFILES_DIR/tests"

    # Copy dot script (from repository root)
    # BATS_TEST_DIRNAME points to the directory containing the test file
    # For tests in tests/unit/, tests/integration/, etc., we need to go up two levels
    local dot_script="$BATS_TEST_DIRNAME/../../dot"
    if [[ ! -f "$dot_script" ]]; then
        # Fallback: try one level up (for tests directly in tests/)
        dot_script="$BATS_TEST_DIRNAME/../dot"
    fi
    cp "$dot_script" "$TEST_DOTFILES_DIR/"

    # Copy manifest files from repository to test directory
    # This is required because the script now auto-discovers packages via manifests
    local repo_root="$BATS_TEST_DIRNAME/../.."
    if [[ ! -d "$repo_root/packages" ]]; then
        # Fallback: try one level up (for tests directly in tests/)
        repo_root="$BATS_TEST_DIRNAME/.."
    fi

    if [[ -d "$repo_root/packages" ]]; then
        # Copy all manifest.toml files from packages/ to test directory
        while IFS= read -r manifest; do
            [[ -z "$manifest" ]] && continue
            local package_dir
            package_dir=$(dirname "$manifest")
            local package_name
            package_name=$(basename "$package_dir")
            local test_package_dir="$TEST_DOTFILES_DIR/packages/$package_name"

            # Create package directory if it doesn't exist
            mkdir -p "$test_package_dir"

            # Copy manifest file
            cp "$manifest" "$test_package_dir/manifest.toml"
        done < <(find "$repo_root/packages" -name "manifest.toml" -type f 2>/dev/null)
    fi
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

    # Use bash arithmetic loop for portability (seq not available on all systems)
    for ((i=1; i<=count; i++)); do
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
        # Try from repository root (two levels up from test file)
        dot_script="$BATS_TEST_DIRNAME/../../dot"
        if [[ ! -f "$dot_script" ]]; then
            # Fallback: one level up
            dot_script="$BATS_TEST_DIRNAME/../dot"
        fi
    fi

    # Source the script to get access to functions
    # Suppress main execution by preventing main() call
    export BATS_TESTING=1
    source "$dot_script"
}

# Fallback assert functions if bats-assert is not available
# These provide basic functionality compatible with bats-assert API

# Assert command succeeded (exit code 0)
if ! command -v assert_success &>/dev/null; then
    assert_success() {
        if [[ "${status:-$?}" -ne 0 ]]; then
            echo "Expected success (exit code 0), got: ${status:-$?}"
            echo "Output: ${output:-}"
            return 1
        fi
    }
fi

# Assert command failed (non-zero exit code)
if ! command -v assert_failure &>/dev/null; then
    assert_failure() {
        if [[ "${status:-$?}" -eq 0 ]]; then
            echo "Expected failure (non-zero exit code), got: 0"
            echo "Output: ${output:-}"
            return 1
        fi
    }
fi

# Assert output matches conditions
if ! command -v assert_output &>/dev/null; then
    assert_output() {
        local flag="${1:-}"
        local expected="${2:-}"

        case "$flag" in
            --partial)
                # Use literal string search instead of regex to avoid escaping issues
                if [[ "$output" != *"$expected"* ]]; then
                    echo "Expected output to contain: $expected"
                    echo "Actual output: $output"
                    return 1
                fi
                ;;
            --regexp)
                if [[ ! "$output" =~ $expected ]]; then
                    echo "Expected output to match regex: $expected"
                    echo "Actual output: $output"
                    return 1
                fi
                ;;
            *)
                # Exact match
                if [[ "$output" != "$flag" ]]; then
                    echo "Expected output: $flag"
                    echo "Actual output: $output"
                    return 1
                fi
                ;;
        esac
    }
fi

# Refute output matches conditions
if ! command -v refute_output &>/dev/null; then
    refute_output() {
        local flag="${1:-}"
        local expected="${2:-}"

        case "$flag" in
            --partial)
                # Use literal string search
                if [[ "$output" == *"$expected"* ]]; then
                    echo "Expected output to NOT contain: $expected"
                    echo "Actual output: $output"
                    return 1
                fi
                ;;
            --regexp)
                if [[ "$output" =~ $expected ]]; then
                    echo "Expected output to NOT match regex: $expected"
                    echo "Actual output: $output"
                    return 1
                fi
                ;;
            *)
                # Exact non-match
                if [[ "$output" == "$flag" ]]; then
                    echo "Expected output to NOT be: $flag"
                    echo "Actual output: $output"
                    return 1
                fi
                ;;
        esac
    }
fi

# Assert two values are equal
if ! command -v assert_equal &>/dev/null; then
    assert_equal() {
        local expected="$1"
        local actual="$2"
        if [[ "$expected" != "$actual" ]]; then
            echo "Expected: $expected"
            echo "Actual: $actual"
            return 1
        fi
    }
fi

# Fail with message
if ! command -v fail &>/dev/null; then
    fail() {
        local message="${1:-Test failed}"
        echo "$message"
        return 1
    }
fi

# Assert directory exists
if ! command -v assert_dir_exists &>/dev/null; then
    assert_dir_exists() {
        local dir="$1"
        if [[ ! -d "$dir" ]]; then
            echo "Directory does not exist: $dir"
            return 1
        fi
    }
fi

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

