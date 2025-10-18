#!/usr/bin/env bash
# Run dotfiles installation
# Bash 3.2 compatible
# Used by both local CI and GitHub CI

# Get script directory (works when sourced or executed)
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/common.sh"

run_installation() {
    log_test_info "Running dotfiles installation..."
    
    # Ensure we're in the dotfiles directory
    if [[ ! -f "./dot" ]]; then
        log_test_error "Cannot find dot script - are you in the dotfiles directory?"
        return 1
    fi
    
    # Make dot script executable
    chmod +x ./dot
    
    # Run installation
    if ./dot install; then
        log_test_success "Installation completed successfully"
        return 0
    else
        log_test_error "Installation failed"
        return 1
    fi
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_installation "$@"
fi

