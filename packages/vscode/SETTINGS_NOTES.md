# VSCode Settings Notes

## Package Creation

This package was created from your existing VSCode configuration and cleaned up
with the same improvements applied to the Cursor package.

## Relationship to Cursor

Cursor is built on VSCode, so many settings are shared. Key differences:

- **Cursor**: Has Cursor-specific settings (`cursor.composer.*`, `cursor.diffs.*`)
- **VSCode**: Pure VSCode without Cursor extensions
- **Both**: Share editor, terminal, language, and extension settings

## Settings Applied

### Cleanup

- Removed commented-out code (byesig regex patterns)
- Removed empty objects (`github.copilot.advanced`)
- Removed empty arrays (`cSpell.languageSettings`)
- Consolidated byesig settings into single block

### Improvements Added

Same as Cursor package:

- ✅ Global editor settings (auto-save, format on save, minimap, bracket guides)
- ✅ Enhanced search exclusions (node_modules, vendor, .bundle, tmp, log)
- ✅ Better file nesting patterns (Ruby, Gemfile, .env, README)
- ✅ More subtle colors (terminal search, comment highlighting with transparency)
- ✅ Additional language settings (YAML, Markdown)
- ✅ TypeScript import updates

### VSCode-Specific Differences

- **Byesig extension**: Enabled in VSCode settings (signature hiding)
  - Not present in Cursor (extension may not be available)
- **diffEditor.ignoreTrimWhitespace**: Set to `false` in VSCode (shows all changes)
  - Set to `true` in Cursor (ignores whitespace in diffs)

## File Size

- **Original**: 188 lines (with commented code and empty objects)
- **Cleaned**: ~260 lines (organized, improved, more capable)

## Cross-Platform Compatibility

**Important:** This package is currently macOS-specific due to different paths:

- **macOS**: `~/Library/Application Support/Code/User/settings.json` ✅ (current package)
- **Linux**: `~/.config/Code/User/settings.json` ❌ (not yet supported)

Unlike Cursor (which uses `.config/Cursor/User/` on both platforms), VSCode uses
platform-specific paths. Future enhancement needed for Linux support.

## Testing Recommendations

After pulling these changes:

1. Restart VSCode to load new settings
2. Verify auto-save works
3. Check comment highlighting is more subtle
4. Test file nesting in explorer
5. Ensure byesig extension still works correctly
