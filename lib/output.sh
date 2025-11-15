#!/usr/bin/env bash
# Generic output formatting, logging, and verbosity helpers
# Tool-agnostic library for consistent output formatting
# Requires: lib/common.sh

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status symbols
SYMBOL_SUCCESS='✓'
SYMBOL_ERROR='✗'
SYMBOL_WARNING='⚠'
SYMBOL_INFO='∙'

# Output formatting
readonly OUTPUT_PREFIX="${DOTFILES_OUTPUT_PREFIX:-│ }"                       # Indentation character

# Global variable for validator error output (used by validation functions)
VALIDATOR_ERROR_OUTPUT=""

# Verbosity level constants (with fun names!)
# These control output behavior throughout the application
readonly VERBOSITY_MUTE=-1          # Silent mode (errors only)
readonly VERBOSITY_TACITURN=0       # Normal output (summary + errors/warnings)
readonly VERBOSITY_LOQUACIOUS=1     # Verbose (add package names and progress)
readonly VERBOSITY_GARRULOUS=2      # Very verbose (show every file operation)

# Logging functions
log_info() {
    echo -e "${BLUE}${SYMBOL_INFO}${NC} $1"
}

log_success() {
    echo -e "${GREEN}${SYMBOL_SUCCESS}${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}${SYMBOL_WARNING}${NC} $1" >&2
}

log_error() {
    echo -e "${RED}${SYMBOL_ERROR}${NC} $1" >&2
}

# Prefix subcommand output for clarity with smart colorization
# Colors lines based on content patterns (errors, warnings, info)
# Generic function - no tool-specific logic
prefix_output() {
    local prefix="${1:-$OUTPUT_PREFIX}"
    while IFS= read -r line; do
        # Skip harmless stow BUG warnings about absolute path mismatches
        # This is tool-specific but commonly needed when using stow
        if [[ "$line" =~ "BUG in find_stowed_path? Absolute/relative mismatch" ]]; then
            continue
        fi

        # Pattern matching for line classification
        if [[ "$line" =~ ^[[:space:]]*(ERROR|error|Error|FAIL|fail|failed|Failed|cannot|Cannot|unable|Unable|fatal|Fatal|FATAL) ]] || \
           [[ "$line" =~ (error:|failed:|fatal:) ]]; then
            # Error patterns - red
            echo -e "${RED}${prefix}${line}${NC}"
        elif [[ "$line" =~ ^[[:space:]]*(WARN|warn|Warn|WARNING|warning|Warning|BUG) ]] || \
             [[ "$line" =~ (warning:|warn:) ]]; then
            # Warning patterns - yellow
            echo -e "${YELLOW}${prefix}${line}${NC}"
        elif [[ "$line" =~ ^[[:space:]]*(SUCCESS|success|Success|OK|ok|Ok|DONE|done|Done|✓|✔) ]] || \
             [[ "$line" =~ (success:|complete:|completed:) ]]; then
            # Success patterns - green
            echo -e "${GREEN}${prefix}${line}${NC}"
        else
            # Info/normal output - blue (subtle)
            echo -e "${BLUE}${prefix}${NC}${line}"
        fi
    done
}

# Generic display formatting functions
# Display a boxed header with title
show_header() {
    local title="$1"
    local verbosity="${2:-${VERBOSITY:-$VERBOSITY_TACITURN}}"

    if [[ $verbosity -eq $VERBOSITY_MUTE ]]; then
        return
    fi

    echo ""
    echo -e "${BLUE}╭──────────────────────────────────────────────────────────╮${NC}"
    printf "${BLUE}│${NC}  %-56s${BLUE}│${NC}\n" "$title"
    echo -e "${BLUE}╰──────────────────────────────────────────────────────────╯${NC}"
    echo ""
}

# Alias for backwards compatibility (if used elsewhere)
show_command_header() {
    show_header "$@"
}

# Display a section separator with title
show_section_separator() {
    local title="$1"
    if [[ -n "$title" ]]; then
        echo -e " ${BLUE}${title}${NC} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    fi
}

# Display a numbered section separator
show_numbered_section() {
    local num="$1"
    local title="$2"
    local verbosity="${3:-${VERBOSITY:-$VERBOSITY_TACITURN}}"

    if [[ $verbosity -eq $VERBOSITY_MUTE ]]; then
        return
    fi

    echo -e " ${BLUE}${num}. ${title}${NC} ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# Display a result summary with optional duration
show_summary() {
    local status="$1"      # "success" or "info"
    local message="$2"
    local duration="$3"     # optional
    local verbosity="${4:-${VERBOSITY:-$VERBOSITY_TACITURN}}"

    if [[ $verbosity -eq $VERBOSITY_MUTE ]]; then
        return
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [[ "$status" == "success" ]]; then
        if [[ -n "$duration" ]]; then
            printf " Result: %b${SYMBOL_SUCCESS} ${message}%b" "$GREEN" "$NC"
            local msg_len=$((10 + ${#message}))  # "Result: ✓ " + message (✓ = 2 cols)
            local padding=$((47 - msg_len))
            [[ $padding -lt 1 ]] && padding=1
            printf "%${padding}s" ""
            printf "Duration: %.1fs\n" "$duration"
        else
            printf " %b${SYMBOL_SUCCESS} ${message}%b\n" "$GREEN" "$NC"
        fi
    else
        printf " %b${SYMBOL_INFO} ${message}%b\n" "$BLUE" "$NC"
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Alias for backwards compatibility (if used elsewhere)
show_command_summary() {
    show_summary "$@"
}

# Display a single tip message
# Usage: show_tip "Tip message" [verbosity]
show_tip() {
    local tip="$1"
    local verbosity="${2:-${VERBOSITY:-$VERBOSITY_TACITURN}}"

    if [[ $verbosity -eq $VERBOSITY_MUTE ]]; then
        return
    fi

    echo -e "${BLUE}💡 Tip: $tip${NC}"
}

# Display titled tips section with multiple items
# Usage: show_tips "Title" "Tip 1" "Tip 2" ... [verbosity]
show_tips() {
    local title="$1"
    shift

    local verbosity="${VERBOSITY:-$VERBOSITY_TACITURN}"
    if [[ $# -gt 0 ]] && [[ "${!#}" =~ ^-?[0-9]+$ ]]; then
        verbosity="${!#}"
        set -- "${@:1:$(($#-1))}"
    fi

    if [[ $verbosity -eq $VERBOSITY_MUTE ]]; then
        return
    fi

    echo ""
    echo -e "${BLUE}💡 ${title}:${NC}"
    while [[ $# -gt 0 ]]; do
        echo "   $1"
        shift
    done
}

# Indent section output (helper for verbosity)
indent_section_output() {
    # Indent 3 spaces and replace any remaining large dots (●) with SYMBOL_INFO (∙)
    # Note: log_info already outputs ∙ via SYMBOL_INFO, but this catches any legacy output
    sed 's/^/   /' | sed "s/●/${SYMBOL_INFO}/g"
}

# Execute command with verbosity-appropriate output
# Usage: run_with_verbosity VERBOSITY THRESHOLD SUCCESS_MSG COMMAND [ARGS...]
# Arguments:
#   VERBOSITY - current verbosity level (0, 1, 2+)
#   THRESHOLD - verbosity level needed to show details (usually 1 or 2)
#   SUCCESS_MSG - message to show if successful and verbosity < threshold
#   COMMAND - command to execute
#   ARGS - arguments to command
# Returns: exit code of command
run_with_verbosity() {
    local verbosity="$1"
    local threshold="$2"
    local success_msg="$3"
    shift 3
    # Remaining args are the command to execute

    # Use -ge comparison: show details if verbosity >= threshold
    if [[ $verbosity -ge $threshold ]]; then
        # Show detailed output (indented)
        # Use pipefail to ensure command exit code is preserved
        local output
        local exit_code
        set -o pipefail
        output=$("$@" 2>&1 | indent_section_output)
        exit_code=$?
        set +o pipefail
        echo "$output"
        return $exit_code
    else
        # Run silently but capture errors for display on failure
        local output
        local exit_code
        set -o pipefail
        output=$("$@" 2>&1)
        exit_code=$?
        set +o pipefail
        if [[ $exit_code -eq 0 ]]; then
            # Show success message if verbosity >= normal (not quiet)
            if [[ -n "$success_msg" ]] && [[ $verbosity -ge $VERBOSITY_TACITURN ]]; then
                echo -e "   ${GREEN}${SYMBOL_SUCCESS}${NC} $success_msg"
            fi
            return 0
        else
            echo "$output" | indent_section_output
            return 1
        fi
    fi
}

# Execute a numbered step with consistent formatting and error handling
# Usage: run_step NUM TITLE VERBOSITY THRESHOLD SUCCESS_MSG ERROR_MSG COMMAND [ARGS...]
run_step() {
    local num="$1"
    local title="$2"
    local verbosity="$3"
    local threshold="$4"
    local success_msg="$5"
    local error_msg="$6"
    shift 6
    # Remaining args are the command

    show_numbered_section "$num" "$title"

    if run_with_verbosity "$verbosity" "$threshold" "$success_msg" "$@"; then
        echo ""
        return 0
    else
        echo ""
        log_error "$error_msg"
        return 1
    fi
}


