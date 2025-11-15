# Ripgrep Package

Ripgrep configuration for fast text search.

## Files Managed

- `.config/ripgrep/ripgreprc` - Ripgrep configuration

## Features

- Smart case sensitivity (case-insensitive for lowercase patterns)
- Follows symlinks
- Searches hidden files
- Excludes common build artifacts and caches
- Colored output with custom color scheme
- Sorted results by path
- Column width limits for readability

## Installation

**Ubuntu/Debian:**

```bash
sudo apt install ripgrep
```

**macOS:**

```bash
brew install ripgrep
```

**Alpine:**

```bash
apk add ripgrep
```

**Enable package:**

```bash
./dot enable ripgrep
```

## Usage

```bash
rg "pattern" .              # Search for pattern in current directory
rg "pattern" --files        # List files matching pattern
rg "pattern" --type rust    # Search only Rust files
rg "pattern" -i             # Case-insensitive search (overrides smart-case)
```

## Configuration

The configuration file is automatically loaded from `~/.config/ripgrep/ripgreprc`.

### Customization

You can override settings on the command line:

```bash
rg "pattern" --no-smart-case    # Disable smart case
rg "pattern" --no-follow         # Don't follow symlinks
rg "pattern" --no-hidden         # Don't search hidden files
```

## Benefits

- Faster than grep for large codebases
- Git-aware (respects .gitignore by default)
- Smart case sensitivity reduces typos
- Colored output improves readability
- Consistent configuration across machines

