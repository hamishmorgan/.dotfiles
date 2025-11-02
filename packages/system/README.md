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

**Install first:** Provides global ignore patterns used by other packages.

## Key Files

**`.stow-global-ignore`:** Ignores `.git`, `.DS_Store`, `*.swp`, temp files

**`.editorconfig`:** 2-space indent, LF endings, UTF-8, trim whitespace, final newline

**`.inputrc`:** Case-insensitive completion, colored listings
