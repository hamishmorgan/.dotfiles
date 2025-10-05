#!/bin/bash
# Validate dotfiles installation

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if file is properly linked
check_symlink() {
    local file="$1"
    local expected_target="$2"
    
    if [[ -L "$HOME/$file" ]]; then
        local target=$(readlink "$HOME/$file")
        if [[ "$target" == *"$expected_target"* ]]; then
            log_success "✓ $file is properly linked to $target"
            return 0
        else
            log_warning "⚠ $file is linked to $target (expected $expected_target)"
            return 1
        fi
    elif [[ -f "$HOME/$file" ]]; then
        log_warning "⚠ $file exists but is not a symlink"
        return 1
    else
        log_error "✗ $file not found"
        return 1
    fi
}


# Validate git configuration
validate_git() {
    log_info "Validating git configuration..."
    
    local git_files=(
        ".gitconfig"
        ".gitattributes"
        ".gitignore-globals"
    )
    
    local git_errors=0
    
    for file in "${git_files[@]}"; do
        if ! check_symlink "$file" ".dotfiles/git"; then
            ((git_errors++))
        fi
    done
    
    # Check if git is working
    if command -v git >/dev/null 2>&1; then
        local git_user=$(git config --global user.name 2>/dev/null || echo "")
        if [[ -n "$git_user" ]]; then
            log_success "✓ Git user.name is set: $git_user"
        else
            log_warning "⚠ Git user.name is not set"
            ((git_errors++))
        fi
        
        local git_email=$(git config --global user.email 2>/dev/null || echo "")
        if [[ -n "$git_email" ]]; then
            log_success "✓ Git user.email is set: $git_email"
        else
            log_warning "⚠ Git user.email is not set"
            ((git_errors++))
        fi
    else
        log_warning "⚠ Git command not found"
        ((git_errors++))
    fi
    
    return $git_errors
}

# Validate zsh configuration
validate_zsh() {
    log_info "Validating zsh configuration..."
    
    local zsh_errors=0
    
    # Check .zshrc
    if ! check_symlink ".zshrc" ".dotfiles/zsh"; then
        ((zsh_errors++))
    fi
    
    # Check Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        if [[ -L "$HOME/.oh-my-zsh" ]]; then
            local target=$(readlink "$HOME/.oh-my-zsh")
            if [[ "$target" == *".dotfiles/zsh"* ]]; then
                log_success "✓ Oh My Zsh is properly linked to dotfiles"
            else
                log_warning "⚠ Oh My Zsh is linked but not to dotfiles: $target"
                ((zsh_errors++))
            fi
        else
            log_info "ℹ Oh My Zsh is installed (not linked from dotfiles)"
        fi
    else
        log_warning "⚠ Oh My Zsh not found"
        ((zsh_errors++))
    fi
    
    # Check if zsh is working
    if command -v zsh >/dev/null 2>&1; then
        log_success "✓ Zsh command found"
        
        # Test if .zshrc can be sourced without errors
        if zsh -c "source $HOME/.zshrc && echo 'Zsh config loaded successfully'" >/dev/null 2>&1; then
            log_success "✓ Zsh configuration loads without errors"
        else
            log_warning "⚠ Zsh configuration has errors"
            ((zsh_errors++))
        fi
    else
        log_warning "⚠ Zsh command not found"
        ((zsh_errors++))
    fi
    
    return $zsh_errors
}

# Validate tmux configuration
validate_tmux() {
    log_info "Validating tmux configuration..."
    
    local tmux_errors=0
    
    # Check .tmux.conf
    if ! check_symlink ".tmux.conf" ".dotfiles/tmux"; then
        ((tmux_errors++))
    fi
    
    # Check if tmux is working
    if command -v tmux >/dev/null 2>&1; then
        log_success "✓ Tmux command found"
        
        # Test if tmux config is valid
        if tmux has-session -t test-session 2>/dev/null; then
            log_info "ℹ Tmux test session already exists"
        else
            if tmux new-session -d -s test-session -c "$HOME" >/dev/null 2>&1; then
                tmux kill-session -t test-session >/dev/null 2>&1
                log_success "✓ Tmux configuration is valid"
            else
                log_warning "⚠ Tmux configuration has errors"
                ((tmux_errors++))
            fi
        fi
    else
        log_warning "⚠ Tmux command not found"
        ((tmux_errors++))
    fi
    
    return $tmux_errors
}

# Check for orphaned symlinks
check_orphaned_symlinks() {
    log_info "Checking for orphaned symlinks..."
    
    local orphaned_found=false
    
    # Check common dotfile locations
    local common_dotfiles=(
        ".bashrc"
        ".bash_profile"
        ".profile"
        ".vimrc"
        ".vim"
        ".emacs"
        ".emacs.d"
    )
    
    for file in "${common_dotfiles[@]}"; do
        if [[ -L "$HOME/$file" ]]; then
            local target=$(readlink "$HOME/$file")
            if [[ "$target" == *".dotfiles"* ]] && [[ ! -e "$HOME/$file" ]]; then
                log_warning "⚠ Orphaned symlink found: $file -> $target"
                orphaned_found=true
            fi
        fi
    done
    
    if [ "$orphaned_found" = false ]; then
        log_success "✓ No orphaned symlinks found"
    fi
}

# Main validation function
main() {
    log_info "Starting dotfiles validation..."
    
    local total_errors=0
    
    # Validate each component
    validate_git || ((total_errors++))
    echo
    
    validate_zsh || ((total_errors++))
    echo
    
    validate_tmux || ((total_errors++))
    echo
    
    check_orphaned_symlinks
    echo
    
    # Summary
    if [ $total_errors -eq 0 ]; then
        log_success "All validations passed! Your dotfiles are properly installed."
        exit 0
    else
        log_error "Validation found $total_errors error(s). Please check the issues above."
        exit 1
    fi
}

# Run main function
main "$@"
