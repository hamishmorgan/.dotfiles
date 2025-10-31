# Development Directory

Contains atomic and composite commands for development workflow.

## Atomic commands (single responsibility)

- `dev/lint-markdown` - Markdown linting only
- `dev/lint-shell` - Shell script linting only
- `dev/smoke` - Smoke tests only
- `dev/bats` - BATS tests only
- `dev/ci` - Local CI only
- `dev/setup` - Development environment setup
- `dev/clean` - Clean temporary files

## Composite commands (orchestration)

- `dev/lint` - All linting (calls lint-markdown && lint-shell)
- `dev/test` - All tests (calls smoke && bats)
- `dev/check` - Complete validation (calls lint && test && ci)
- `dev/help` - Show available commands

## Design principle

Atomic commands do one thing, composite commands orchestrate multiple atomic commands.
This enables flexible workflows: use atomic commands for fast iteration, composite for comprehensive checks.
