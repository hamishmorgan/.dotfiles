# Agent Instructions

Instructions for AI agents working with this dotfiles repository.

## Project Context

This repository contains dotfiles managed with GNU Stow. Files are organized into packages: git, zsh, tmux. Oh My Zsh is included as a submodule within the zsh package.

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

- Package-specific files go in their respective directories (git/, zsh/, tmux/)
- Scripts (install.sh, validate.sh) remain in root
- Configuration files use dot-prefixed names
- .gitignore is project-specific, not managed by stow

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

## Common Tasks

- Installation: Use `./install.sh`
- Validation: Use `./validate.sh`
- Package management: Use `stow -v package_name`
- Backup location: `~/.dotfiles-backup-*`

