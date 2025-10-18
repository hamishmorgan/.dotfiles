#!/usr/bin/env bash
# Run CI tests locally using Docker
# Tests on both Ubuntu and Alpine (BSD-like) environments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Parse arguments
PLATFORM="${1:-all}"

run_test() {
    local platform="$1"
    local dockerfile="$2"
    local test_result=0

    echo -e "${BLUE}Testing on $platform...${NC}"
    echo ""

    # Build image
    echo "Building container image..."
    if ! $CONTAINER_RUNTIME build -t "dotfiles-test-$platform" -f "$SCRIPT_DIR/docker/$dockerfile" "$SCRIPT_DIR/docker"; then
        echo -e "${RED}✗ Build failed for $platform${NC}"
        return 1
    fi

    # Run tests
    echo ""
    echo "Running tests..."
    if $CONTAINER_RUNTIME run --rm \
        -v "$DOTFILES_DIR:/dotfiles:ro" \
        -v "$SCRIPT_DIR/docker/test-in-container.sh:/test.sh:ro" \
        "dotfiles-test-$platform" \
        bash /test.sh; then
        echo ""
        echo -e "${GREEN}✓ $platform tests passed${NC}"
    else
        echo ""
        echo -e "${RED}✗ $platform tests failed${NC}"
        test_result=1
    fi

    # Clean up image to prevent disk space accumulation
    echo "Cleaning up test image..."
    $CONTAINER_RUNTIME rmi -f "dotfiles-test-$platform" >/dev/null 2>&1 || true

    return $test_result
}

# Detect container runtime (Podman or Docker)
detect_container_runtime() {
    if command -v podman >/dev/null 2>&1; then
        echo "podman"
    elif command -v docker >/dev/null 2>&1; then
        echo "docker"
    else
        return 1
    fi
}

# Main execution
echo -e "${BLUE}Local CI Test Runner${NC}"
echo "===================="
echo ""

# Check container runtime is available
CONTAINER_RUNTIME=$(detect_container_runtime)
if [[ -z "$CONTAINER_RUNTIME" ]]; then
    echo -e "${RED}Error: Neither Docker nor Podman is installed${NC}"
    echo "Install one of:"
    echo "  - Docker: https://docs.docker.com/get-docker/"
    echo "  - Podman: https://podman.io/getting-started/installation"
    exit 1
fi

echo -e "${BLUE}Using container runtime: ${CONTAINER_RUNTIME}${NC}"
echo ""

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

# Final cleanup of any dangling images/layers
echo ""
echo -e "${BLUE}Cleaning up dangling images...${NC}"
$CONTAINER_RUNTIME image prune -f >/dev/null 2>&1 || true

