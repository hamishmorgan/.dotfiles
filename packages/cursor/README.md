# Cursor IDE Configuration Package

Manages Cursor IDE user settings and keybindings across machines with cross-platform support.

## Package Structure

This package uses a **dual-path structure** to support both macOS and Linux:

```text
packages/cursor/
├── .config/Cursor/User/           # Primary (Linux standard, XDG)
│   ├── settings.json              # Source of truth
│   └── keybindings.json           # Source of truth
└── Library/Application Support/Cursor/User/  # macOS compatibility (committed symlinks)
    ├── settings.json → ../../../../.config/Cursor/User/settings.json
    └── keybindings.json → ../../../../.config/Cursor/User/keybindings.json
```

## How It Works

### Cross-Platform Paths

Cursor uses different paths on different platforms:

- **macOS**: `~/Library/Application Support/Cursor/User/`
- **Linux**: `~/.config/Cursor/User/`
- **Windows**: `%APPDATA%\Cursor\User\` (not yet supported)

### Dual-Path Strategy

1. **Primary location**: `.config/Cursor/User/` (Linux standard)
   - All settings maintained here
   - Single source of truth

2. **macOS compatibility**: `Library/Application Support/Cursor/User/`
   - Contains symlinks (committed to repo) pointing to `.config` files
   - Enables stow to create a double-symlink chain on macOS

3. **Platform-specific stowing**:
   - **macOS**: `stow --ignore=.config cursor` → Only stows Library path
   - **Linux**: `stow --ignore=Library cursor` → Only stows .config path

### Result

**On macOS:**

```text
~/Library/Application Support/Cursor/User/settings.json
  → ~/.dotfiles/packages/cursor/Library/.../settings.json
    → ~/.dotfiles/packages/cursor/.config/Cursor/User/settings.json
```

**On Linux:**

```text
~/.config/Cursor/User/settings.json
  → ~/.dotfiles/packages/cursor/.config/Cursor/User/settings.json
```

Both platforms read the same settings file!

## Installation

The `./dot install` command handles everything automatically:

1. Detects your platform (macOS or Linux)
2. Creates internal symlinks if needed (macOS: Library → .config)
3. Stows only the appropriate path for your platform

```bash
./dot install        # Automatic platform detection and setup
./dot install -vv    # Show which path is being used
```

No manual setup required!

## What This Manages

**Manages:**

- User-level Cursor settings (preferences, theme, extensions)
- Keyboard shortcuts and keybindings
- Synced across all your machines

**Does NOT manage:**

- Project-specific rules (`.cursor/rules/*.mdc`)
- Workspace settings (`.vscode/settings.json` in projects)

**Note:** Project-specific rules should be managed per-project using Shopify's standard
`.cursor/rules/*.mdc` approach.

## Platform Support

| Platform | Status | Path |
|----------|--------|------|
| macOS    | ✅ Supported | `~/Library/Application Support/Cursor/User/` |
| Linux    | ✅ Supported | `~/.config/Cursor/User/` |
| Windows  | ❌ Not yet | `%APPDATA%\Cursor\User\` |

## Technical Details

### Why This Approach?

**Alternative approaches considered:**

1. **Separate packages** (cursor-macos, cursor-linux)
   - Rejected: Duplicate settings maintenance

2. **Custom symlink script** (bypass stow)
   - Rejected: Breaks stow consistency

3. **Template generation** (generate per-platform)
   - Rejected: Adds complexity

**Chosen approach:**

- Uses stow's native `--ignore` flag
- Single package, single source of truth
- Minimal custom logic in `dot` script
- Surgical precision (only affects cursor/vscode)

### Implementation in dot script

The internal symlinks are committed to the repository for reliability. The install script also includes defensive
logic to create/verify them:

```bash
# Create/verify internal symlinks (Library → .config)
setup_dual_path_symlinks() {
    # Creates symlinks if missing or broken
    # Ensures: packages/cursor/Library/.../User/settings.json
    #       → packages/cursor/.config/Cursor/User/settings.json
}

# Get platform-specific ignore flag for stow
get_platform_ignore() {
    if is_dual_path_package "$package"; then
        case "$(detect_platform)" in
            macos) echo "--ignore=.config" ;;  # Stow only Library path
            linux) echo "--ignore=Library" ;;  # Stow only .config path
        esac
    fi
}

# Stow with platform-specific ignore
stow $stow_flags $(get_platform_ignore "$package") "$package"
```

## Maintenance

### Updating Settings

Edit the files in `.config/Cursor/User/` (primary location):

```bash
cd ~/.dotfiles/packages/cursor/.config/Cursor/User
vim settings.json
```

Changes sync automatically via the symlink chain on macOS.

### Adding VSCode

The same pattern can be used for VSCode:

1. Create `.config/Code/User/settings.json` (primary)
2. Symlink from `Library/Application Support/Code/User/` (macOS)
3. Add `vscode` to `is_dual_path_package()` function
4. Stow handles the rest

## See Also

- Main documentation: `/README.md`
- Settings cleanup notes: `SETTINGS_NOTES.md`
- Dot script: `/dot`
