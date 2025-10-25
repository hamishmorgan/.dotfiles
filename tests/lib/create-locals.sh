#!/usr/bin/env bash
# Create .local files for testing
# Replaces the old create-secrets.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Create .gitconfig.local for testing
create_gitconfig_local() {
    cat > "$HOME/.gitconfig.local" << 'EOF'
# Test configuration
[user]
    email = test@example.com
    name = Test User
    username = testuser
EOF
    chmod 600 "$HOME/.gitconfig.local"
}

# Main execution
create_gitconfig_local

echo "Created .local files for testing"

