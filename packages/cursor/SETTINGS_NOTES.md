# Cursor Settings Cleanup Notes

## Changes Made

### Cleanup (First Pass)

- **Removed all commented-out code** (~100 lines):
  - Disabled "byesig" configuration block
  - Empty "github.copilot.advanced" object
  - Massive duplicate "highlight.regexes" block
- **Removed empty/redundant settings**:
  - `"cSpell.languageSettings": []` (empty array)

### Improvements (Second Pass)

#### 1. Global Editor Settings Added

```json
"editor.formatOnSave": true,           // Auto-format on save
"editor.minimap.enabled": true,        // Enable minimap
"editor.minimap.showSlider": "always", // Always show scrollbar
"editor.bracketPairColorization.enabled": true,  // Colorize brackets
"editor.guides.bracketPairs": true,    // Show bracket guides
"files.autoSave": "onFocusChange",     // Auto-save when focus changes
"files.trimTrailingWhitespace": true,  // Clean whitespace globally
"files.insertFinalNewline": true,      // Ensure final newline
"breadcrumbs.enabled": true            // Enable breadcrumb navigation
```

#### 2. Search Exclusions

```json
"search.exclude": {
  "**/node_modules": true,
  "**/bower_components": true,
  "**/.git": true,
  "**/vendor": true,
  "**/.bundle": true,
  "**/tmp": true,
  "**/log": true,
  "**/*.log": true
}
```

#### 3. Enhanced File Nesting Patterns

Added nesting for:

- Ruby test/spec files: `"*.rb": "${capture}_test.rb, ${capture}_spec.rb"`
- Gemfile: `"Gemfile": "Gemfile.lock"`
- Environment files: `".env": ".env.*, .envrc"`
- Documentation: `"README.md": "README*, CHANGELOG*, CONTRIBUTING*, LICENSE*"`
- Enabled file nesting by default: `"explorer.fileNesting.enabled": true`

#### 4. Terminal Colors

Terminal search highlighting uses bright yellow for visibility:

```json
"terminal.findMatchBackground": "#dddd00",
"terminal.findMatchHighlightBackground": "#dddd00"
```

Note: Could be improved with semi-transparent colors (e.g., `#ffcc0060`) for better theme integration.

#### 5. Comment Highlighting

Comment markers use bright opaque colors for high visibility:

- TODO: `#ffcc00` (bright yellow)
- FIXME/BUG: `#cc0000` (bright red)
- REVIEW: `#00ccff` (bright cyan)
- IDEA: `#cc00cc` (bright magenta)

Note: Could be improved with semi-transparent colors for better theme integration:
`#ffcc0040`, `#ff6b6b40`, `#4ecdc440`, `#c678dd40`

#### 6. Ruby Settings Enhanced

```json
"editor.quickSuggestions": {
  "comments": true  // Enable suggestions in comments
},
"editor.suggest.showWords": false  // Don't suggest random words
```

#### 7. Additional Language Settings

Added sensible defaults for:

- YAML: 2-space indentation, auto-indent
- Markdown: Word wrap, disable autocomplete
- TypeScript: Auto-update imports on file move

## Organization

Settings grouped into logical sections:

1. **Cursor-Specific Settings** - Cursor IDE features
2. **Editor - Global Settings** - Cross-language editor behavior
3. **Editor Appearance & Workbench** - Theme, icons, UI density
4. **Git & Version Control** - Git, GitHub, GitLens
5. **Terminal** - Scrollback, images, search highlighting
6. **File Explorer** - Nesting patterns, behavior
7. **Language-Specific Settings** - Ruby, JSON, YAML, Markdown, etc.
8. **Extensions** - Third-party extension config
9. **Remote Development** - SSH settings

## File Size

- **Original**: 267 lines (with commented code)
- **After cleanup**: 240 lines (organized, no dead code)
- **After improvements**: 274 lines (added useful features)

Net result: Slightly larger but significantly more capable and maintainable.

## Deferred Improvements

### Split Shopify-Specific Settings (Future)

These settings could be moved to shopify branch when you implement branch-specific config:

- Ruby LSP configuration (`rubyLsp.featureFlags`)
- Sorbet highlighting (`sorbet.highlightUntyped`)
- Many cSpell words: "Shipify", "merch", "metafield", "fulfillable", "unfulfill"

**Strategy**: Keep current unified settings for now, split when needed.

## Cross-Platform Compatibility

**Full cross-platform support** using dual-path structure:

- **macOS**: `~/Library/Application Support/Cursor/User` ✅
- **Linux**: `~/.config/Cursor/User` ✅

**How it works:**

- Primary files stored in `.config/Cursor/User/` (Linux/XDG standard)
- macOS `Library/` path contains symlinks to `.config` files
- Install script uses platform-specific `--ignore` flag:
  - macOS: `stow --ignore=.config` (only stows Library path)
  - Linux: `stow --ignore=Library` (only stows .config path)

Both platforms read the same settings via the symlink chain!

## Testing Recommendations

After pulling these changes:

1. Restart Cursor to load new settings
2. Verify auto-save works (`files.autoSave`)
3. Check comment highlighting is more subtle
4. Test file nesting in explorer (should hide test files under source files)
5. Verify Ruby LSP still works correctly
