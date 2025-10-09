# Agent Instructions

Instructions for AI agents working with this dotfiles repository.

## Project Context

This repository contains dotfiles managed with GNU Stow. Files are organized into packages:

- **system**: System-wide configuration files (`.stow-global-ignore`)
- **git**: Git configuration and global ignore patterns
- **zsh**: Zsh shell configuration (includes Oh My Zsh as submodule)
- **tmux**: Terminal multiplexer configuration
- **gh**: GitHub CLI configuration
- **gnuplot**: GNU Plot configuration
- **bash**: Bash shell configuration

Template-based secrets management separates public templates from private secret configurations.
The `system` package is stowed first to ensure `.stow-global-ignore` is in place before other packages.

### Branch Strategy

- **main branch**: Personal configurations for home use
- **shopify branch**: Work environment configurations (Shopify-specific tools and settings)
  - Rebase on main to pull in general improvements
  - Allow dev tools to modify files freely without affecting main
  - Push auto-generated changes without concern

## Documentation Standards

- Use formal, minimal, reserved tone
- Use technically precise language
- Eliminate unnecessary words
- Avoid marketing language, exclamations, or enthusiasm
- Be direct and concise
- Focus on essential information only

## Code Standards

- Follow existing patterns and structure
- Maintain consistency with current implementations
- Use clear, descriptive variable names
- Include error handling where appropriate
- Keep functions focused and single-purpose
- Use long-form arguments for CLI commands where available (e.g., `--verbose` not `-v`)
- Use explicit error handling instead of `set -e` (controlled failure handling)
- Enable bash safety features: `shopt -s nullglob extglob`

## File Organization

- Package-specific files go in their respective directories (system/, git/, zsh/, tmux/, gh/, gnuplot/, bash/)
- Scripts (`dot`) remain in root
- Configuration files use dot-prefixed names
- `.gitignore` is project-specific, not managed by stow

### Stow Ignore Files

- **`system/.stow-global-ignore`**: Symlinked to `~/.stow-global-ignore`, contains universal patterns
  for all stow operations
- **Package `.stow-local-ignore`**: In each package directory (e.g., `git/.stow-local-ignore`),
  contains package-specific ignore patterns
- Template/secret/example files are ignored via `.stow-local-ignore` in each package

### Templates and Secrets

- Templates (`.template` files) contain placeholders for sensitive information
- Secret configs (`.secret` files) are git-ignored and contain actual sensitive values
- Example files (`.example` files) show format for secret configs
- **These files are NOT stowed** - ignored via package `.stow-local-ignore` files
- Installation script merges templates with secret configs during installation

### Platform-Specific Configs

- OS-specific configs use suffixes: `.bashrc.osx`, `.bashrc.linux`, `.zshrc.osx`, `.zshrc.linux`

## Logging System

The `dot` script uses symbol-based logging for clear, scannable output:

- `●` (blue) - Informational messages
- `✓` (green) - Success messages
- `⚠` (yellow) - Warnings
- `✗` (red) - Errors

Subcommand output is prefixed with `│` and colorized based on content:

- Red: error patterns (error, failed, fatal, cannot, unable)
- Yellow: warning patterns (warning, warn)
- Green: success patterns (success, ok, done, complete)
- Blue prefix: normal output

## Validation

- All changes should pass validation script
- Symlinks must point to dotfiles repository
- Dependencies must be properly checked
- Backup functionality must be preserved

## Update Instructions

**This file must be updated whenever new guidance is provided during conversations.**

When adding new instructions:

- Maintain the formal, minimal tone
- Be technically precise
- Include only essential information
- Update the timestamp or version if needed

## Code Quality

- All Markdown files must pass markdownlint validation
- All Bash scripts must pass shellcheck validation
- Configuration files: `.markdownlint.yml`, `.shellcheckrc`
- Linting runs as prerequisite in CI before validation tests
- **Always run linting after making changes to verify code quality**

## CI/CD

- GitHub Actions workflow validates installation on Ubuntu and macOS
- Uses `apt-get` for stable package management in scripts
- Tests full installation pipeline including dependency checks
- Linting job must pass before validation jobs run

## Common Tasks

- Installation: `./dot install`
- Validation: `./dot validate`
- Health check: `./dot health`
- Status: `./dot status`
- Linting: `markdownlint "**/*.md"` and `shellcheck dot`
- Package management: `stow --verbose --restow --dir=. --target=$HOME package_name`
- Backup location: `backups/dotfiles-backup-*` (timestamped directories)
- CI validation: `.github/workflows/validate.yml`

## Pull Request Workflow

For all code changes:

1. **Create Pull Request**: Use GitHub MCP to raise PR
2. **Request Copilot Review**: Use `mcp_github_request_copilot_review`
3. **Wait for CI**: Monitor CI status until passing
4. **Wait for Copilot Review**: Review Copilot feedback
5. **Address Issues**: Fix any problems identified
6. **Repeat**: Continue until both CI and Copilot approve
7. **Merge**: Only merge after both CI and Copilot are satisfied

This ensures code quality through automated testing and AI review.
