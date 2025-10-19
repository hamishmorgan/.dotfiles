#!/usr/bin/env bash
# Backward compatibility wrapper for CI and existing workflows
# Redirects to: dev/ci

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

exec "$REPO_ROOT/dev/ci" "$@"
