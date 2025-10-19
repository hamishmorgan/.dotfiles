#!/usr/bin/env bash
# Create test secret files
# Bash 3.2 compatible
# Used by both local CI and GitHub CI

# Get script directory (works when sourced or executed)
LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$LIB_DIR/common.sh"

create_test_secrets() {
    log_test_info "Creating test secret files..."
    
    # Git secrets
    cat > packages/git/.gitconfig.secret << 'EOF'
[user]
	name = Test User
	email = test@example.com
EOF
    
    if [[ -f packages/git/.gitconfig.secret ]]; then
        log_test_success "Created packages/git/.gitconfig.secret"
    else
        log_test_error "Failed to create packages/git/.gitconfig.secret"
        return 1
    fi
    
    # GitHub CLI secrets
    mkdir -p packages/gh/.config/gh
    
    cat > packages/gh/.config/gh/config.yml.secret << 'EOF'
editor: vim
git_protocol: ssh
EOF
    
    if [[ -f packages/gh/.config/gh/config.yml.secret ]]; then
        log_test_success "Created packages/gh/.config/gh/config.yml.secret"
    else
        log_test_error "Failed to create packages/gh/.config/gh/config.yml.secret"
        return 1
    fi
    
    cat > packages/gh/.config/gh/hosts.yml.secret << 'EOF'
github.com:
    user: testuser
    oauth_token: test_token_12345
    git_protocol: ssh
EOF
    
    if [[ -f packages/gh/.config/gh/hosts.yml.secret ]]; then
        log_test_success "Created packages/gh/.config/gh/hosts.yml.secret"
    else
        log_test_error "Failed to create packages/gh/.config/gh/hosts.yml.secret"
        return 1
    fi
    
    log_test_success "All test secrets created"
    return 0
}

# Allow direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    create_test_secrets "$@"
fi

