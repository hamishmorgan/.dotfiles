#!/usr/bin/env bash
# Smoke test for dotfiles installation
# Quick validation that basic functionality works

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}Running dotfiles smoke tests...${NC}"
echo ""

# Test 1: Script executes without errors
echo -n "Test 1: Script help displays... "
if "$DOTFILES_DIR/dot" --help >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 2: All required commands available in script
echo -n "Test 2: Required commands defined... "
if grep -q "cmd_install\|cmd_validate\|cmd_health\|cmd_status" "$DOTFILES_DIR/dot"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 3: All packages defined
echo -n "Test 3: All packages defined... "
if grep -q 'PACKAGES=("system" "git" "zsh" "tmux" "gh" "gnuplot" "bash")' "$DOTFILES_DIR/dot"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 4: Template files exist
echo -n "Test 4: Template files exist... "
if [[ -f "$DOTFILES_DIR/git/.gitconfig.template" ]] && \
   [[ -f "$DOTFILES_DIR/gh/.config/gh/config.yml.template" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 5: Stow ignore files exist
echo -n "Test 5: Stow ignore files exist... "
if [[ -f "$DOTFILES_DIR/system/.stow-global-ignore" ]] && \
   [[ -f "$DOTFILES_DIR/git/.stow-local-ignore" ]] && \
   [[ -f "$DOTFILES_DIR/gh/.stow-local-ignore" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 6: System package files exist
echo -n "Test 6: System package complete... "
if [[ -f "$DOTFILES_DIR/system/.stow-global-ignore" ]] && \
   [[ -f "$DOTFILES_DIR/system/.stowrc" ]] && \
   [[ -f "$DOTFILES_DIR/system/.editorconfig" ]] && \
   [[ -f "$DOTFILES_DIR/system/.inputrc" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 7: Backup directory exists
echo -n "Test 7: Backup directory exists... "
if [[ -d "$DOTFILES_DIR/backups" ]] && [[ -f "$DOTFILES_DIR/backups/.gitkeep" ]]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

# Test 8: Shellcheck passes
echo -n "Test 8: Shellcheck passes... "
if command -v shellcheck >/dev/null 2>&1; then
    if shellcheck "$DOTFILES_DIR/dot" >/dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⊘ (shellcheck not installed)${NC}"
fi

# Test 9: Markdownlint passes
echo -n "Test 9: Markdownlint passes... "
if command -v markdownlint >/dev/null 2>&1; then
    if markdownlint "$DOTFILES_DIR"/**/*.md 2>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}⊘ (markdownlint not installed)${NC}"
fi

# Test 10: Logging functions use symbols
echo -n "Test 10: Symbol-based logging... "
if grep -q 'SYMBOL_INFO=' "$DOTFILES_DIR/dot" && \
   grep -q 'SYMBOL_SUCCESS=' "$DOTFILES_DIR/dot" && \
   grep -q 'SYMBOL_WARNING=' "$DOTFILES_DIR/dot" && \
   grep -q 'SYMBOL_ERROR=' "$DOTFILES_DIR/dot" && \
   grep -q 'SYMBOL_INFO}' "$DOTFILES_DIR/dot" && \
   grep -q 'SYMBOL_SUCCESS}' "$DOTFILES_DIR/dot"; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}All smoke tests passed!${NC}"

