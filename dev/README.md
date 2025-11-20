# Development Directory

Contains atomic development scripts located in this directory.

## Scripts

- `dev/test-smoke` - Smoke tests only
- `dev/test-bats` - BATS tests only
- `dev/ci` - Local CI only
- `dev/update-gitignore` - Refresh global gitignore patterns
- `dev/validate-jsonc` - Validate JSONC configs
- `dev/validate-tmux` - Validate tmux configs

Each script is single-responsibility and can be composed by tooling (e.g., `make`) outside this directory.
