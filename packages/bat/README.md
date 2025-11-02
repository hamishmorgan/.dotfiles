# Bat Package

Bat syntax highlighter configuration.

## Files Managed

- `.config/bat/config` - Bat configuration

## Features

- **Syntax highlighting** - Enhanced code display
- **Git integration** - Shows git modifications in files
- **Line numbers** - Automatic line numbering
- **Paging** - Integrated with less for long files

## Installation

```bash
./dot enable bat
```

## Prerequisites

Install bat:

```bash
# macOS
brew install bat

# Ubuntu/Debian (via cargo)
cargo install bat

# Or download binary from GitHub releases
```

## Usage

After installation, bat uses the configuration automatically:

```bash
bat filename.rs      # View file with syntax highlighting
bat -p filename.rs   # Plain output (no line numbers)
```

## Aliases

Common aliases for bat:
- `cat` → `bat` (if you prefer bat as default cat replacement)

Note: Aliases are not included by default. Add to your `.bashrc.local` or `.zshrc.local` if desired.

