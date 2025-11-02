# System Package

System-wide configuration files used by all packages.

## Files Managed

- `.stow-global-ignore` - Global ignore patterns for stow operations
- `.stowrc` - Stow runtime configuration
- `.editorconfig` - Editor configuration (consistent formatting)
- `.inputrc` - Readline input configuration

## Features

- **Global stow ignore patterns** - Applies to all package installations
- **Editor consistency** - Unified formatting across editors (VS Code, vim, etc.)
- **Readline configuration** - Enhanced shell input behavior
- **Stow defaults** - Common stow settings

## Installation

```bash
./dot enable system
```

**Note:** This package should typically be installed first as it provides global ignore patterns used by other packages.

## What's Included

**`.stow-global-ignore`:**

- Ignores `.git`, `.DS_Store`, `*.swp`, temp files
- Applied to all stow operations automatically

**`.editorconfig`:**

- 2-space indentation for shell scripts
- LF line endings
- UTF-8 encoding
- Trim trailing whitespace
- Insert final newline

**`.inputrc`:**

- Case-insensitive completion
- Show all completions immediately
- Colored completion listings

## What Makes This Different

**Foundation package:** Other packages depend on the ignore patterns defined here. Install this first to avoid stow conflicts.
