#!/usr/bin/env bash
# Test script that runs inside Docker container
# Performs full installation and validation in clean environment

set -e

echo "================================"
echo "Testing dotfiles in container"
echo "OS: $(uname -s)"
echo "================================"
echo ""

# Copy dotfiles to home directory
cp -r /dotfiles ~/.dotfiles
cd ~/.dotfiles

# Initialize submodules
git submodule update --init --recursive

# Create minimal secret files for testing
mkdir -p git gh/.config/gh

cat > git/.gitconfig.secret << 'EOF'
[user]
	name = Test User
	email = test@example.com
EOF

cat > gh/.config/gh/config.yml.secret << 'EOF'
editor: vim
EOF

cat > gh/.config/gh/hosts.yml.secret << 'EOF'
github.com:
    user: testuser
    oauth_token: test_token
EOF

# Run installation
echo "Testing installation..."
./dot install

# Run validation
echo ""
echo "Testing validation..."
./dot validate

# Run health check
echo ""
echo "Testing health check..."
./dot health

# Check that symlinks were created
echo ""
echo "Verifying symlinks..."
for file in .gitconfig .zshrc .tmux.conf .bashrc; do
    if [[ -L ~/$file ]] || [[ -d ~/$file ]]; then
        echo "✓ $file exists"
    else
        echo "✗ $file missing"
        exit 1
    fi
done

echo ""
echo "✅ All tests passed successfully!"

