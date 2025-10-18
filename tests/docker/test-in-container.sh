#!/usr/bin/env bash
# Test script that runs inside Docker container
# Performs full installation and validation in clean environment
# Uses shared test library scripts

set -e

# Source shared test utilities
source /tests/lib/common.sh
source /tests/lib/create-secrets.sh
source /tests/lib/run-installation.sh
source /tests/lib/verify-health.sh

log_test_section "Testing dotfiles in container"
echo "OS: $(uname -s)"
echo "Bash: $BASH_VERSION"
echo ""

# Copy dotfiles to home directory using tar (handles all edge cases)
log_test_info "Copying dotfiles to test environment..."
mkdir -p ~/.dotfiles
if ! tar -C /dotfiles -cf - --exclude='.git' . 2>/dev/null | tar -C ~/.dotfiles -xf -; then
    log_test_warning "Some files may not have copied correctly"
fi

cd ~/.dotfiles

# Initialize submodules
log_test_info "Initializing submodules..."
if ! git submodule update --init --recursive 2>&1 | grep -qv "fatal: not a git repository"; then
    log_test_info "Submodule initialization skipped (expected in container)"
fi

# Create test secrets using shared function
log_test_section "Creating Test Secrets"
if ! create_test_secrets; then
    log_test_error "Failed to create test secrets"
    exit 1
fi

# Run installation using shared function
log_test_section "Running Installation"
if ! run_installation; then
    log_test_error "Installation failed"
    exit 1
fi

# Run health check using shared function
# verify_health with allow_warnings=true will:
#   - Return 0 if passed or has only warnings
#   - Return 1 and log error if critical failures found
log_test_section "Running Health Checks"
verify_health true || exit 1

# Verify symlinks were created
log_test_section "Verifying Symlinks"
symlink_failures=0
for file in .gitconfig .zshrc .tmux.conf .bashrc; do
    if [[ -L ~/$file ]]; then
        log_test_success "$file exists (symlink)"
    elif [[ -d ~/$file ]]; then
        log_test_success "$file exists (directory)"
    else
        log_test_error "$file missing or invalid"
        symlink_failures=$((symlink_failures + 1))
    fi
done

if [[ $symlink_failures -gt 0 ]]; then
    log_test_error "Symlink verification failed: $symlink_failures file(s) missing"
    exit 1
fi

echo ""
log_test_success "All tests passed successfully!"

