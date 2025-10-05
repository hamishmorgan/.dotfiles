#!/bin/bash
# Install dotfiles using GNU Stow

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%s)"

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

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check dependencies
check_dependencies() {
    log_info "Checking dependencies..."
    
    local missing_deps=()
    
    if ! command_exists stow; then
        missing_deps+=("stow")
    fi
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if ! command_exists zsh; then
        missing_deps+=("zsh")
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            case "$dep" in
                stow)
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        echo "  brew install stow"
                    else
                        echo "  sudo apt install stow  # or equivalent package manager"
                    fi
                    ;;
                git)
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        echo "  brew install git"
                    else
                        echo "  sudo apt install git  # or equivalent package manager"
                    fi
                    ;;
                zsh)
                    if [[ "$OSTYPE" == "darwin"* ]]; then
                        echo "  brew install zsh"
                    else
                        echo "  sudo apt install zsh  # or equivalent package manager"
                    fi
                    ;;
            esac
        done
        exit 1
    fi
    
    log_success "All dependencies found"
}

# Detect platform
detect_platform() {
    case "$OSTYPE" in
        darwin*)
            PLATFORM="macos"
            log_info "Detected platform: macOS"
            ;;
        linux-gnu*)
            PLATFORM="linux"
            log_info "Detected platform: Linux"
            ;;
        *)
            log_warning "Unknown platform: $OSTYPE"
            PLATFORM="unknown"
            ;;
    esac
}

# Backup existing files
backup_existing() {
    log_info "Checking for existing files to backup..."
    
    local files_to_backup=(
        ".gitconfig"
        ".gitattributes"
        ".gitignore-globals"
        ".zshrc"
        ".tmux.conf"
    )
    
    local need_backup=false
    
    for file in "${files_to_backup[@]}"; do
        if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
            need_backup=true
            break
        fi
    done
    
    if [ "$need_backup" = true ]; then
        log_info "Creating backup directory: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        
        for file in "${files_to_backup[@]}"; do
            if [[ -f "$HOME/$file" && ! -L "$HOME/$file" ]]; then
                cp "$HOME/$file" "$BACKUP_DIR/"
                log_info "Backed up $file"
            fi
        done
        
        log_success "Backup completed in $BACKUP_DIR"
    else
        log_info "No existing files need backup"
    fi
}

# Initialize submodules
init_submodules() {
    log_info "Initializing git submodules..."
    
    if [ -f "$DOTFILES_DIR/.gitmodules" ]; then
        cd "$DOTFILES_DIR"
        git submodule update --init --recursive
        log_success "Submodules initialized"
    else
        log_info "No submodules found"
    fi
}

# Install dotfiles using Stow
install_dotfiles() {
    log_info "Installing dotfiles using Stow..."
    
    cd "$DOTFILES_DIR"
    
    # Define packages to install
    local packages=("git" "zsh" "tmux")
    
    for package in "${packages[@]}"; do
        if [ -d "$package" ]; then
            log_info "Installing package: $package"
            stow -v -R "$package"
            log_success "Installed $package"
        else
            log_warning "Package $package not found, skipping"
        fi
    done
}

# Validate installation
validate_installation() {
    log_info "Validating installation..."
    
    local files_to_check=(
        ".gitconfig"
        ".gitattributes"
        ".gitignore-globals"
        ".zshrc"
        ".tmux.conf"
    )
    
    local all_good=true
    
    for file in "${files_to_check[@]}"; do
        if [[ -L "$HOME/$file" ]]; then
            local target=$(readlink "$HOME/$file")
            if [[ "$target" == *".dotfiles"* ]]; then
                log_success "✓ $file is properly linked"
            else
                log_warning "⚠ $file is linked but not to dotfiles"
                all_good=false
            fi
        elif [[ -f "$HOME/$file" ]]; then
            log_warning "⚠ $file exists but is not a symlink"
            all_good=false
        else
            log_error "✗ $file not found at $HOME/$file"
            all_good=false
        fi
    done
    
    if [ "$all_good" = true ]; then
        log_success "Installation validation passed"
    else
        log_warning "Installation validation found issues"
        return 1
    fi
}

# Platform-specific setup
platform_setup() {
    case "$PLATFORM" in
        macos)
            log_info "Running macOS-specific setup..."
            
            # Check for Homebrew
            if command_exists brew; then
                log_info "Homebrew found"
            else
                log_warning "Homebrew not found. Consider installing it:"
                echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
            fi
            
            # Check for Oh My Zsh
            if [ -d "$HOME/.oh-my-zsh" ]; then
                log_info "Oh My Zsh found"
            else
                log_warning "Oh My Zsh not found. Consider installing it:"
                echo "  sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
            fi
            ;;
        linux)
            log_info "Running Linux-specific setup..."
            
            # Check for Oh My Zsh
            if [ -d "$HOME/.oh-my-zsh" ]; then
                log_info "Oh My Zsh found"
            else
                log_warning "Oh My Zsh not found. Consider installing it:"
                echo "  sh -c \"\$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\""
            fi
            ;;
    esac
}

# Main installation function
main() {
    log_info "Installing dotfiles"
    
    cd "$DOTFILES_DIR"
    
    check_dependencies
    detect_platform
    backup_existing
    init_submodules
    install_dotfiles
    
    if validate_installation; then
        platform_setup
        log_success "Installation complete"
        log_info "Restart shell or run 'source ~/.zshrc'"
        
        if [ -d "$BACKUP_DIR" ]; then
            log_info "Backup: $BACKUP_DIR"
        fi
    else
        log_error "Installation validation failed"
        exit 1
    fi
}

# Run main function
main "$@"
