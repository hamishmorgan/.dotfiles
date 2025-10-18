#!/usr/bin/env bash
# Run health check verification
# Bash 3.2 compatible
# Used by both local CI and GitHub CI

# Get script directory (works when sourced or executed)
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/common.sh"

verify_health() {
    local allow_warnings="${1:-true}"
    
    log_test_info "Running health checks..."
    
    # Ensure we're in the dotfiles directory
    if [[ ! -f "./dot" ]]; then
        log_test_error "Cannot find dot script - are you in the dotfiles directory?"
        return 1
    fi
    
    # Run health check
    local health_output
    local health_result
    
    health_output=$(./dot health 2>&1)
    health_result=$?
    
    # In container environments, some warnings are expected
    if [[ $health_result -eq 0 ]]; then
        log_test_success "Health check passed"
        return 0
    elif [[ "$allow_warnings" == "true" ]]; then
        # Check if it's just warnings (not critical errors)
        if echo "$health_output" | grep -q "FAIL"; then
            log_test_error "Health check found critical failures"
            echo "$health_output"
            return 1
        else
            log_test_warning "Health check completed with warnings (expected in containers)"
            return 0
        fi
    else
        log_test_error "Health check failed"
        echo "$health_output"
        return 1
    fi
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    verify_health "$@"
fi

