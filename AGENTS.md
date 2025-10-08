# Agent Instructions

Instructions for AI agents working with this dotfiles repository.

## Project Context

This repository contains dotfiles managed with GNU Stow. Files are organized into packages: git, zsh, tmux, bash.
Oh My Zsh is included as a submodule within the zsh package.
Template-based secrets management separates public templates from private secret configurations.

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

## File Organization

- Package-specific files go in their respective directories (git/, zsh/, tmux/, bash/)
- Scripts (dot) remain in root
- Configuration files use dot-prefixed names
- .gitignore is project-specific, not managed by stow
- Templates (.template files) contain placeholders for sensitive information
- Secret configs (.secret files) are git-ignored and contain actual sensitive values
- Installation script merges templates with secret configs during installation
- OS-specific configs (.bashrc.osx, .bashrc.linux, .zshrc.osx, .zshrc.linux) for platform differences

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

- Installation: Use `./dot install`
- Validation: Use `./dot validate`
- Linting: `markdownlint "**/*.md"` and `shellcheck dot`
- Package management: Use `stow -v package_name`
- Backup location: `~/.dotfiles-backup-*`
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
