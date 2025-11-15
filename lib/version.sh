#!/usr/bin/env bash
# Version checking and comparison utilities
# Requires: lib/common.sh (for command_exists)

# Get minimum version for a tool (bash 3.2 compatible - no associative arrays)
get_min_version() {
    local tool="$1"
    case "$tool" in
        git)  echo "2.0.0" ;;
        stow) echo "2.3" ;;
        *)    echo "" ;;  # No minimum version requirement
    esac
}

# Compare semantic versions (returns 0 if $1 >= $2)
# Works on both Linux (GNU sort) and macOS (BSD sort)
version_ge() {
    local v1="$1"
    local v2="$2"

    # Try GNU sort -V (Linux)
    if printf '%s\n%s\n' "$v2" "$v1" | sort -V -C 2>/dev/null; then
        return 0
    elif [[ $? -eq 2 ]]; then
        # Exit code 2 means sort -V not supported, try gsort (Homebrew)
        if command -v gsort >/dev/null 2>&1; then
            printf '%s\n%s\n' "$v2" "$v1" | gsort -V -C
            return $?
        fi

        # Fall back to bash-native comparison
        _version_ge_fallback "$v1" "$v2"
        return $?
    else
        # Exit code 1 means sort -V worked but comparison failed
        return 1
    fi
}

# Fallback version comparison for systems without sort -V (bash 3.2 compatible)
# Returns 0 if $1 >= $2
_version_ge_fallback() {
    local v1="$1"
    local v2="$2"

    # Split versions by dots (IFS localized to read command)
    IFS=. read -ra ver1 <<< "$v1"
    IFS=. read -ra ver2 <<< "$v2"

    # Compare each component
    local max_len=${#ver1[@]}
    [[ ${#ver2[@]} -gt $max_len ]] && max_len=${#ver2[@]}

    local i
    for ((i=0; i<max_len; i++)); do
        local num1="${ver1[i]:-0}"
        local num2="${ver2[i]:-0}"

        # Strip letters from end (e.g., "3a" -> "3")
        num1="${num1%%[a-z]*}"
        num2="${num2%%[a-z]*}"

        # Compare numerically
        if ((10#$num1 > 10#$num2)); then
            return 0
        elif ((10#$num1 < 10#$num2)); then
            return 1
        fi
    done

    # All components equal
    return 0
}

# Check specific tool version and return current version on stdout
# Returns: 0 if version >= minimum, 1 otherwise
check_tool_version() {
    local tool="$1"
    local min_version="$2"
    local current_version=""

    case "$tool" in
        git)
            current_version=$(git --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1)
            ;;
        stow)
            current_version=$(stow --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n 1)
            ;;
    esac

    # Output current version for caller
    echo "$current_version"

    if [[ -z "$current_version" ]]; then
        return 1  # Could not determine version
    fi

    if version_ge "$current_version" "$min_version"; then
        return 0  # Version is sufficient
    else
        return 1  # Version is too old
    fi
}

