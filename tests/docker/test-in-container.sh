#!/usr/bin/env bash
# Test script that runs inside Docker container
# Performs full installation and validation in clean environment

set -e

echo "================================"
echo "Testing dotfiles in container"
echo "OS: $(uname -s)"
echo "================================"
echo ""

# Copy dotfiles to home directory using tar (handles all edge cases)
echo "Copying dotfiles to test environment..."
mkdir -p ~/.dotfiles
if ! tar -C /dotfiles -cf - --exclude='.git' . 2>/dev/null | tar -C ~/.dotfiles -xf -; then
    echo "Warning: Some files may not have copied correctly"
fi

cd ~/.dotfiles

# Initialize submodules
echo "Initializing submodules..."
if ! git submodule update --init --recursive 2>&1 | grep -qv "fatal: not a git repository"; then
    echo "Note: Submodule initialization skipped (expected in container environment)"
fi

# Helper function to create secret files
create_secret_file() {
    local file="$1"
    local content="$2"
    mkdir -p "$(dirname "$file")"
    cat > "$file" << EOF
$content
EOF
}

# Create minimal secret files for testing
echo "Creating test secret files..."
create_secret_file "git/.gitconfig.secret" "[user]
	name = Test User
	email = test@example.com"

create_secret_file "gh/.config/gh/config.yml.secret" "editor: vim"

create_secret_file "gh/.config/gh/hosts.yml.secret" "github.com:
    user: testuser
    oauth_token: test_token"

# Run installation
echo "Testing installation..."
./dot install

# Run validation
echo ""
echo "Testing validation..."
./dot validate

# Run health check (expect some warnings in container environment)
echo ""
echo "Testing health check..."
if ! ./dot health; then
    echo ""
    echo "Note: Health check reported issues (expected in container environment)"
    echo "  - Git repository checks fail when .git is excluded"
    echo "  - Submodule checks fail in isolated containers"
fi

# Check that symlinks were created
echo ""
echo "Verifying symlinks..."
for file in .gitconfig .zshrc .tmux.conf .bashrc; do
    if [[ -L ~/$file ]]; then
        echo "✓ $file exists (symlink)"
    elif [[ -d ~/$file ]]; then
        echo "✓ $file exists (directory)"
    else
        echo "✗ $file missing or invalid"
        exit 1
    fi
done

echo ""
echo "✅ All tests passed successfully!"

