# Cursor Settings Cleanup Notes

## Changes Made

### Removed
- **Commented out code** (lines 26-109 in original):
  - Disabled "byesig" configuration block
  - Disabled "github.copilot.advanced" empty object
  - Massive commented out "highlight.regexes" block (duplicate of active config)
- **Empty/redundant settings**:
  - `"cSpell.languageSettings": []` (empty array adds no value)

### Organized Into Sections
1. **Cursor-Specific Settings** - Composer, diffs, window behavior
2. **Editor Appearance & Behavior** - Theme, icons, tabs
3. **Git & Version Control** - Git, GitHub, GitLens config
4. **Terminal** - Scrollback, images, search highlighting
5. **File Explorer** - File nesting patterns for cleaner tree view
6. **Language-Specific Settings** - Ruby, JSON, Docker, YAML
7. **Extensions** - Ruby LSP, Sorbet, cSpell, highlight patterns
8. **Remote Development** - SSH timeout

### Improvements Made
- Added clear section headers with visual separators
- Grouped related settings together
- Kept all active/useful settings
- Maintained proper JSON formatting
- Added inline comments for clarity

## Suggestions for Further Improvement

### 1. **Consider Splitting Shopify-Specific Settings**
These settings might be better suited for your `shopify` branch:
- Ruby LSP configuration
- Sorbet highlighting
- Most cSpell words (many are Shopify-specific: "merch", "metafield", "Shipify")

**Recommendation**: Create a minimal `main` branch version and a fuller `shopify` branch version.

### 2. **Review cSpell Words**
Many words in the dictionary seem Shopify/work-specific:
- **Keep in main**: General terms like "autofetch", "scrollback", "regexes"
- **Move to shopify branch**: "Shipify", "merch", "metafield", "metafields", "fulfillable", "unfulfill"

### 3. **Consider Adding Useful Global Settings**
You might want to add:
```json
// Auto-save
"files.autoSave": "onFocusChange",

// Format on save globally (not just Ruby)
"editor.formatOnSave": true,

// Trim trailing whitespace globally
"files.trimTrailingWhitespace": true,
"files.insertFinalNewline": true,

// Better minimap
"editor.minimap.enabled": true,
"editor.minimap.showSlider": "always",

// Breadcrumbs
"breadcrumbs.enabled": true,

// Exclude from search
"search.exclude": {
  "**/node_modules": true,
  "**/bower_components": true,
  "**/.git": true,
  "**/vendor": true
}
```

### 4. **File Nesting Patterns - Add More**
Consider adding nesting for:
```json
"*.rb": "${capture}_test.rb, ${capture}_spec.rb",
"Gemfile": "Gemfile.lock",
".env": ".env.*",
"README.md": "README*"
```

### 5. **Terminal Color Customization**
The terminal search highlighting is bright yellow (`#dddd00`). Consider:
- Making it more subtle or theme-aware
- Adding other terminal color customizations

### 6. **Comment Highlighting Colors**
Current colors are very bright/saturated:
- TODO: `#ffcc00` (bright yellow)
- FIXME: `#cc0000` (bright red)  
- REVIEW: `#00ccff` (bright cyan)
- IDEA: `#cc00cc` (bright magenta)

**Suggestion**: Use theme-aware or more subtle colors, or add transparency.

### 7. **Ruby Settings Consolidation**
The Ruby-specific settings in `[ruby]` are comprehensive but could be enhanced:
```json
"[ruby]": {
  // ... existing settings ...
  "editor.quickSuggestions": {
    "comments": true
  },
  "editor.suggest.showWords": false
}
```

## Recommended Next Steps

1. **Test the cleaned settings** - Restart Cursor and verify everything works
2. **Create shopify branch variant** - Move work-specific settings there
3. **Minimize main branch** - Keep only truly universal settings
4. **Document customizations** - Add comments explaining non-obvious choices
5. **Version control keybindings** - Review and clean those up too

## Settings File Size
- **Before**: 267 lines (lots of commented code)
- **After**: ~240 lines (organized, no dead code)
- **Further optimization**: Could reduce to ~150 lines by removing Shopify-specific items

## Cross-Platform Compatibility
All settings should work on both macOS and Linux. No platform-specific settings detected.

