#!/usr/bin/env bash
# Common test utilities
# Bash 3.2 compatible
# Used by both local CI and GitHub CI

# Colors for test output
readonly TEST_RED='\033[0;31m'
readonly TEST_GREEN='\033[0;32m'
readonly TEST_BLUE='\033[0;34m'
readonly TEST_YELLOW='\033[0;33m'
readonly TEST_NC='\033[0m'

# Test symbols
readonly TEST_SUCCESS="✓"
readonly TEST_ERROR="✗"
readonly TEST_WARNING="⚠"
readonly TEST_INFO="∙"

# Logging functions
log_test_success() {
    echo -e "${TEST_GREEN}${TEST_SUCCESS}${TEST_NC} $1"
}

log_test_error() {
    echo -e "${TEST_RED}${TEST_ERROR}${TEST_NC} $1"
}

log_test_warning() {
    echo -e "${TEST_YELLOW}${TEST_WARNING}${TEST_NC} $1"
}

log_test_info() {
    echo -e "${TEST_BLUE}${TEST_INFO}${TEST_NC} $1"
}

# Section header
log_test_section() {
    echo ""
    echo -e "${TEST_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TEST_NC}"
    echo -e "${TEST_BLUE}$1${TEST_NC}"
    echo -e "${TEST_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${TEST_NC}"
    echo ""
}

