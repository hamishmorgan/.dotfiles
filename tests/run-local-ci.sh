#!/usr/bin/env bash
# Run CI tests locally using Docker
# Tests on both Ubuntu and Alpine (BSD-like) environments

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly DOTFILES_DIR

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Show help
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [PLATFORM] [OPTIONS]"
    echo ""
    echo "Platforms:"
    echo "  ubuntu      Test on Ubuntu only"
    echo "  alpine      Test on Alpine only"
    echo "  all         Test on both platforms (default)"
    echo ""
    echo "Options:"
    echo "  --no-cleanup    Keep test images for debugging"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0                    # Run all tests"
    echo "  $0 ubuntu             # Test Ubuntu only"
    echo "  $0 all --no-cleanup   # Run all tests, keep images"
    exit 0
fi

# Parse arguments
PLATFORM="${1:-all}"
NO_CLEANUP=false

# Check for --no-cleanup flag in any position
for arg in "$@"; do
    if [[ "$arg" == "--no-cleanup" ]]; then
        NO_CLEANUP=true
        break
    fi
done

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
    if [[ "$NO_CLEANUP" == "false" ]]; then
        echo "Cleaning up test image..."
        if $CONTAINER_RUNTIME inspect "dotfiles-test-$platform" >/dev/null 2>&1; then
            $CONTAINER_RUNTIME rmi "dotfiles-test-$platform" >/dev/null 2>&1 || true
        fi
    else
        echo "Skipping cleanup (--no-cleanup flag set)"
        echo "To remove later: $CONTAINER_RUNTIME rmi dotfiles-test-$platform"
    fi

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
if [[ "$NO_CLEANUP" == "false" ]]; then
    echo ""
    echo -e "${BLUE}Cleaning up dangling images...${NC}"
    $CONTAINER_RUNTIME image prune -f >/dev/null 2>&1 || true
fi
