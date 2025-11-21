# Git Package

Git configuration with aliases, diff tools, and platform-specific settings.

## Files Managed

- `.gitconfig` - Main git configuration
- `.gitattributes` - Git attributes for file handling
- `.gitignore-globals` - Global gitignore patterns
- `.gitconfig.delta` - Optional git-delta diff viewer configuration

## Features

- **Aliases and shortcuts** - Common git operations
- **Color configuration** - Enhanced diff and status colors
- **Diff tools** - Configured for various file types with graceful fallbacks
- **Shopify-specific configuration** - Pre-configured for Shopify development
- **Git-delta support** - Optional enhanced diff viewer (requires manual activation)

### Textconv Tools

Git is configured to display readable diffs for binary/compressed files using textconv tools. These tools are **optional** - if not installed, Git falls back to raw file display.

**Standard tools** (included with macOS):
- `tar`, `unzip`, `hexdump`

**Optional tools** (enhanced diffs, install via Homebrew):
- `gzcat`, `bzcat`, `xzcat` - Compressed file viewing
  ```bash
  brew install gzip bzip2 xz
  ```
- `odt2txt` - OpenDocument format diffs
  ```bash
  brew install odt2txt
  ```
- `pdfinfo` - PDF metadata viewing
  ```bash
  brew install poppler
  ```

The health check (`./dot health`) will warn about missing optional tools.

## Installation

```bash
./dot enable git
```

## Machine-Specific Configuration

Create `~/.gitconfig.local` for per-machine settings:

```bash
cp packages/git/.gitconfig.local.example ~/.gitconfig.local
nano ~/.gitconfig.local
```

**Required settings:**

- User name and email
- Signing configuration (1Password, GPG, or disabled)

**Optional settings:**

- Machine-specific aliases
- Private repository credentials
- Tool paths

## Git Delta Integration

For enhanced diff viewing, install [git-delta](https://github.com/dandavison/delta) and add to `~/.gitconfig.local`:

```gitconfig
[include]
    path = ~/.gitconfig.delta
```

## Update

Global gitignore patterns can be updated:

```bash
./dot update  # Runs dev/update-gitignore automatically
```

Or manually:

```bash
curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/linux,osx,vscode,vim,jetbrains > ~/.gitignore-globals
```
