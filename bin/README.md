# Bin Directory

Standalone utilities independent of dotfiles management.

## disk-cleanup

Disk space cleanup utility for developer caches and build artifacts.

### Key characteristics

- **Independent of dotfiles management**: Not tied to `./dot` script or stow
- **Comprehensive tool coverage**: 25+ developer tools across 7 categories
- **Safe defaults**: Non-destructive operations, confirmation prompts for risky actions
- **Environment variable configuration**: All settings configurable via `CLEANUP_*` vars
- **Bash 3.2 compatible**: No external dependencies
- **Cross-platform**: macOS and Linux support

### Implementation notes

- Uses same logging patterns as `./dot` script (symbols, colors, prefixed output)
- Protected main() execution for testing (only runs when not sourced)
- All configuration via readonly variables with env var overrides
- Helper functions for size conversion, directory measurement, git repo discovery
- Categories can be filtered with `--only` and `--exclude` flags
- Multiple aggression levels for Docker cleanup (default safe, --aggressive, --very-aggressive)
- Git cleanup uses `--auto` by default (safe), `--prune-git`, or `--aggressive-git`
- Comprehensive logging to `~/.cache/dev-cleanup/` with retention policy

### Testing

- Integration tests in `tests/integration/test_clean_basic.bats`
- Tests use core bats only (no bats-assert dependency)
- 26 test cases covering all major functionality
- Includes bash 3.2 compatibility checks and shellcheck validation
