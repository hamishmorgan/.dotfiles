#!/usr/bin/env bash
# Run CI tests locally using Docker
# Tests on both Ubuntu and Alpine (BSD-like) environments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
PLATFORM="${1:-all}"

run_test() {
    local platform="$1"
    local dockerfile="$2"
    
    echo -e "${BLUE}Testing on $platform...${NC}"
    echo ""
    
    # Build image
    echo "Building Docker image..."
    if ! docker build -t dotfiles-test-$platform -f "$SCRIPT_DIR/docker/$dockerfile" "$SCRIPT_DIR/docker"; then
        echo -e "${RED}✗ Docker build failed for $platform${NC}"
        return 1
    fi
    
    # Run tests
    echo ""
    echo "Running tests..."
    if docker run --rm \
        -v "$DOTFILES_DIR:/dotfiles:ro" \
        -v "$SCRIPT_DIR/docker/test-in-container.sh:/test.sh:ro" \
        dotfiles-test-$platform \
        bash /test.sh; then
        echo ""
        echo -e "${GREEN}✓ $platform tests passed${NC}"
        return 0
    else
        echo ""
        echo -e "${RED}✗ $platform tests failed${NC}"
        return 1
    fi
}

# Main execution
echo -e "${BLUE}Local CI Test Runner${NC}"
echo "===================="
echo ""

# Check Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Install Docker to run local CI tests"
    exit 1
fi

case "$PLATFORM" in
    ubuntu)
        run_test "ubuntu" "Dockerfile.ubuntu"
        ;;
    alpine)
        run_test "alpine" "Dockerfile.alpine"
        ;;
    all)
        echo "Testing on all platforms..."
        echo ""
        
        if ! run_test "ubuntu" "Dockerfile.ubuntu"; then
            echo -e "${RED}Ubuntu tests failed${NC}"
            exit 1
        fi
        
        echo ""
        echo "=========================================="
        echo ""
        
        if ! run_test "alpine" "Dockerfile.alpine"; then
            echo -e "${RED}Alpine tests failed${NC}"
            exit 1
        fi
        
        echo ""
        echo -e "${GREEN}✅ All platform tests passed!${NC}"
        ;;
    *)
        echo -e "${RED}Unknown platform: $PLATFORM${NC}"
        echo "Usage: $0 [ubuntu|alpine|all]"
        exit 1
        ;;
esac

