# Cursor IDE Configuration Package

Manages Cursor IDE settings using a **copy-sync approach** instead of symlinks.

## Why Copy-Sync Instead of Symlinks?

Cursor (based on VSCode) does not handle symlinked configuration files well. Users report:

- Broken commands and CLI tools
- Indexing failures
- Permission issues

Therefore, this package uses a copy-based sync approach where:

- **Source of truth**: `packages/cursor/` (platform-agnostic)
- **Target location (macOS)**: `~/Library/Application Support/Cursor/User/`
- **Target location (Linux)**: `~/.config/Cursor/User/`
- **Sync method**: `./dot sync-cursor` copies files from dotfiles to system location

## Usage

```bash
# Sync Cursor configs from dotfiles to system
./dot sync-cursor

# After making changes in Cursor, pull them back to dotfiles
./dot pull-cursor

# Then commit the updated configs
git add packages/cursor
git commit -m "update cursor settings"
```

## What's Managed

- `settings.json` - All editor preferences
- `keybindings.json` - Custom keyboard shortcuts

## What's Not Managed

- Extensions list (manage via Cursor's extension sync)
- Extension-specific data
- Workspace settings (project-specific)
- Machine-specific caches

## Platform Support

- ✅ **macOS**: Fully supported (`~/Library/Application Support/Cursor/User/`)
- ✅ **Linux**: Implemented but untested (`~/.config/Cursor/User/`)

The package source (`packages/cursor/`) is platform-agnostic. The sync commands handle platform-specific paths automatically.
