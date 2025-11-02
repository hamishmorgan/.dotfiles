# Cursor IDE Configuration Package

Manages Cursor IDE settings using a **copy-sync approach** instead of symlinks.

## Why Copy-Sync Instead of Symlinks?

Cursor (based on VSCode) does not handle symlinked configuration files well. Users report:

- Broken commands and CLI tools
- Indexing failures
- Permission issues

**Research findings (Issue #104):**

Comprehensive web research found:

- **Zero successful examples** of symlinking entire Cursor User directory
- **One claimed success** with file-level symlinks, but many failures reported
- **Community consensus**: Copy-based sync is the only reliable approach
- Cursor forum discussions confirm symlink issues disrupt functionality

Both directory-level and file-level symlinks fail. Therefore, this package uses a copy-based sync approach.

## Usage

```bash
# Sync Cursor configs from dotfiles to system
./dot sync cursor

# After making changes in Cursor, pull them back to dotfiles
./dot pull cursor

# Then commit the updated configs
git add packages/cursor
git commit -m "update cursor settings"
```

### Workflow

```bash
# After making changes in Cursor
./dot pull cursor                   # Pull changes to dotfiles
git diff packages/cursor            # Review changes
git add packages/cursor             # Stage if satisfied
git commit -m "update cursor settings"

# On another machine
git pull                            # Get latest dotfiles
./dot sync cursor                   # Apply to local Cursor
# Restart Cursor to apply
```

## Integration Notes

- **Cursor uses copy-sync method** - Defined in manifest.toml with `method = "copy-sync"`
- **Cursor appears in `./dot packages` output** - But is managed with `sync`/`pull` instead of symlinks
- **Use `./dot sync cursor` and `./dot pull cursor`** - Not the enable/disable commands

## Machine-Specific Settings Pattern

To avoid hardcoded user paths in shared configs, use empty strings or platform detection:

**❌ BAD (hardcoded path breaks other users):**

```json
"rubyLsp.rubyExecutablePath": "/home/hamish/.local/share/mise/shims/ruby"
```

**✅ GOOD (empty string enables auto-detection):**

```json
"rubyLsp.rubyExecutablePath": ""
```

**✅ GOOD (alternatives for machine-specific paths):**

- Leave empty - let Cursor/Copilot/Ruby LSP auto-detect the path
- Users can override in Cursor's User Settings directly (per-machine customization)
- Use relative paths or environment variables if supported by the extension

**Critical:** Settings in `settings.json` must work across all machines. Never hardcode user paths:

- User home directory paths (`/home/USERNAME/`, `/Users/USERNAME/`)
- Machine-specific installation paths
- Absolute local paths

Use empty strings for auto-detection, let users override in Cursor, or use relative paths.

## What's Managed

- `settings.json` - All editor preferences (platform-agnostic, no hardcoded paths)
- `keybindings.json` - Custom keyboard shortcuts (cross-platform with when conditions)

## What's Not Managed

- Extensions list (manage via Cursor's extension sync)
- Extension-specific data
- Workspace settings (project-specific)
- Machine-specific caches

## File Structure

```text
packages/cursor/
├── README.md             # Documentation (this file)
├── settings.json         # Platform-agnostic settings (no hardcoded paths)
└── keybindings.json      # Cross-platform keybindings (with when conditions)
```

## Platform Support

- ✅ **macOS**: Fully supported (`~/Library/Application Support/Cursor/User/`)
- ✅ **Linux**: Implemented but untested (`~/.config/Cursor/User/`)

The package source (`packages/cursor/`) is platform-agnostic. The sync commands handle platform-specific paths automatically.

## Why This Matters

Not all tools integrate with symlink-based dotfiles. Copy-sync provides a fallback pattern for tools that:

- Write to their own config locations
- Check that config directories are real directories
- Use file watchers that don't follow symlinks
- Have permission/security checks that fail with symlinks

Other tools that may need copy-sync: VSCode, certain IDE extensions, any tool that explicitly rejects symlinked configs.
