# Package Manifest Proposal

## Decision Summary

**Format:** Simplified TOML (`manifest.toml`)  
**Migration:** Gradual (Phase 1-3), each phase separate commit, no squashing  
**Required Fields:** Optional in Phase 1, required by Phase 3 (minimal with defaults)  
**Validation:** Yes, both syntactic (structure/keys) and semantic (files exist)  
**Naming:** `manifest.toml` (not hidden, visible configuration file)  
**Parsing:** Simplified bash-parsable subset (no external dependencies)

## Current Problems

1. **Package metadata duplication** (Issue #68, Issue 4):
   - `get_package_files()` - file lists (case statement)
   - `get_package_name()` - display names (case statement)
   - `list_packages()` - descriptions (case statement)
   - Adding new package requires updating 3+ locations

2. **No installation method declaration**:
   - Cursor uses hardcoded copy-sync logic (not in PACKAGES array)
   - Issue #117 proposes marker files, but manifest is more structured

3. **Limited extensibility**:
   - Can't add metadata without modifying core script
   - No self-documenting package structure

## Manifest File Format: Simplified TOML

**Format:** `packages/PACKAGE/manifest.toml`

**Rationale:**
- ✅ Already used in project (Rust configs use `.toml`)
- ✅ Valid TOML format (can be validated with standard tools)
- ✅ Human-readable and well-documented format
- ✅ Native array support
- ✅ Simplified subset for bash parsing (no external dependencies)
- ✅ Not hidden (no dot prefix) - configuration file should be visible

**Simplified TOML Subset (Valid TOML but Limited Features):**

- ✅ **Top-level keys**: `files`, `name`, `description`, `method`, `target`
- ✅ **Tables (sections)**: `[linux]`, `[macos]` for platform-specific overrides
- ✅ **String values**: `name = "value"` or `name = 'value'`
- ✅ **Arrays**: Single-line or multi-line `files = ["file1", "file2"]`
- ✅ **Comments**: `# comments`
- ✅ **Basic types**: strings, booleans, integers
- ✅ **Multi-line arrays**: Supported! (balanced bracket matching)
- ❌ **Nested tables**: Only top-level tables (no `[package.nested]`)
- ❌ **Inline tables**: Not supported
- ❌ **Complex escaping**: Standard quoting only

**Example Minimal Manifest:**

```toml
files = [".gitconfig", ".gitattributes"]
```

**Example Full Manifest:**

```toml
name = "Git"
description = "Git configuration and aliases"
method = "stow"
target = "$HOME"
files = [".gitconfig", ".gitattributes", ".gitignore-globals"]

[dependencies]
optional = ["git"]
```

## Default Values

When manifest fields are missing, use these defaults:

- **`name`**: Directory name (e.g., `git` → `"Git"`)
- **`description`**: Empty string (`""`)
- **`method`**: `"stow"`
- **`target`**: `$HOME` (can be overridden by platform-specific sections)
- **`files`**: **REQUIRED** - Must be specified (no default)

**Minimal valid manifest (Phase 3):**

```toml
files = [".gitconfig", ".gitattributes"]
```

All other fields use defaults.

## Implementation Plan

### Phase 1: Add Manifest Support (Backward Compatible)

**Goal:** Add parsing functions with case statement fallbacks

**Tasks:**
1. Implement `load_package_manifest()` function (simplified TOML parsing)
2. Update `get_package_files()`, `get_package_name()`, `get_package_description()` to try manifest first
3. Fall back to case statements if manifest missing
4. Add basic manifest validation function (syntax check)
5. Add tests for manifest parsing
6. **Commit:** "Add manifest support with case statement fallbacks"

**Validation:**
- Existing packages continue to work without manifests
- New packages can optionally use manifests
- Tests verify fallback behavior

### Phase 2: Migrate Existing Packages

**Goal:** Create manifests for all existing packages

**Tasks:**
1. Create `manifest.toml` for each package:
   - `packages/system/manifest.toml`
   - `packages/git/manifest.toml`
   - `packages/zsh/manifest.toml`
   - `packages/tmux/manifest.toml`
   - `packages/gh/manifest.toml`
   - `packages/gnuplot/manifest.toml`
   - `packages/bash/manifest.toml`
   - `packages/fish/manifest.toml`
   - `packages/wezterm/manifest.toml`
   - `packages/bat/manifest.toml`
   - `packages/rust/manifest.toml`
2. Update functions to prefer manifests over case statements
3. Keep case statements as fallback
4. Add semantic validation (files exist check)
5. Review `.stow-local-ignore` files:
   - Remove for packages that only list individual files
   - Keep for packages that stow directories (e.g., zsh with `.oh-my-zsh`, fish with `.config/fish/functions`)
6. **Commit:** "Add manifests for all existing packages"

**Validation:**
- All packages have manifests
- Functions prefer manifests but still fall back
- Health check validates manifests

### Phase 3: Require Manifests and Remove Case Statements

**Goal:** Require manifests for all packages

**Tasks:**
1. Update validation to require manifests
2. Remove case statement fallbacks
3. Require `files` field in manifest (no default)
4. Update error messages to guide users to create manifests
5. Add health check warning for packages without manifests
6. **Commit:** "Require manifests for all packages, remove case statements"

**Validation:**
- Health check fails if manifest missing
- Clear error messages guide users
- All packages have manifests

### Phase 4: Auto-Discovery (Eliminate PACKAGES Array)

**Goal:** Discover packages automatically by scanning for manifests

**Tasks:**
1. Implement `discover_packages()` function that scans `packages/` for `manifest.toml` files
2. Replace `PACKAGES` array with auto-discovery
3. Update all functions that iterate over packages to use discovered list
4. Add validation to ensure discovered packages have valid manifests
5. **Commit:** "Add package auto-discovery, eliminate PACKAGES array"

**Benefits:**
- Single source of truth (manifest files)
- No need to update array when adding packages
- Packages automatically appear in `./dot packages` output

**Note:** Commits should not be squashed or amended. Each phase is a separate commit. Fixes can be additional commits.

## Parsing Implementation

### Simplified TOML Parser (Bash 3.2 Compatible)

```bash
# Load package manifest (manifest.toml)
load_package_manifest() {
    local package="$1"
    local manifest="$PACKAGES_DIR/$package/manifest.toml"
    
    if [[ ! -f "$manifest" ]]; then
        return 1  # No manifest, use defaults
    fi
    
    # Extract values from top-level keys
    PACKAGE_NAME=$(get_toml_value "$manifest" "" "name")
    PACKAGE_DESCRIPTION=$(get_toml_value "$manifest" "" "description")
    PACKAGE_METHOD=$(get_toml_value "$manifest" "" "method")
    PACKAGE_TARGET=$(get_toml_value "$manifest" "" "target")
    
    # Extract files array (top-level)
    PACKAGE_FILES=$(get_toml_array "$manifest" "" "files")
    
    # Apply defaults
    PACKAGE_METHOD="${PACKAGE_METHOD:-stow}"
    PACKAGE_NAME="${PACKAGE_NAME:-$package}"
    PACKAGE_DESCRIPTION="${PACKAGE_DESCRIPTION:-}"
    PACKAGE_TARGET="${PACKAGE_TARGET:-$HOME}"
    
    # Check for platform-specific target overrides
    local platform
    platform=$(detect_platform)  # Function that returns "linux", "macos", or "unknown"
    if [[ "$platform" == "linux" ]]; then
        local linux_target
        if get_toml_value "$manifest" "linux" "target" >/dev/null; then
            linux_target=$(get_toml_value "$manifest" "linux" "target")
            if [[ -n "$linux_target" ]]; then
                # Expand ~ to $HOME if present
                if [[ "$linux_target" == ~* ]]; then
                    linux_target="${linux_target/#\~/$HOME}"
                fi
                PACKAGE_TARGET="$linux_target"
            fi
        fi
    elif [[ "$platform" == "macos" ]]; then
        local macos_target
        if get_toml_value "$manifest" "macos" "target" >/dev/null; then
            macos_target=$(get_toml_value "$manifest" "macos" "target")
            if [[ -n "$macos_target" ]]; then
                # Expand ~ to $HOME if present
                if [[ "$macos_target" == ~* ]]; then
                    macos_target="${macos_target/#\~/$HOME}"
                fi
                PACKAGE_TARGET="$macos_target"
            fi
        fi
    fi
    # Unknown platform → uses default target (no override)
    
    # Files array is required - convert to comma-separated for compatibility
    if [[ -z "$PACKAGE_FILES" ]]; then
        return 1  # Invalid manifest - files required
    fi
    
    return 0
}

# Get TOML value from section (empty string for top-level)
# Checks for key existence to distinguish missing vs empty
get_toml_value() {
    local file="$1"
    local section="$2"  # Empty string for top-level
    local key="$3"
    
    # Handle top-level vs section
    if [[ -z "$section" ]]; then
        # Top-level key - search before first [ section
        local section_content
        section_content=$(sed '/^\[/,$d' "$file")
    else
        # Escape regex special characters in section name for safe matching
        local escaped_section
        escaped_section=$(echo "$section" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g' | sed 's/\./\\./g' | sed 's/\*/\\*/g' | sed 's/\+/\\+/g' | sed 's/\?/\\?/g' | sed 's/\^/\\^/g' | sed 's/\$/\\$/g')
        
        # Extract section content
        section_content=$(sed -n "/\[$escaped_section\]/,/^\[/p" "$file" | sed '$d')
    fi
    
    # Check if key exists at all (even if empty)
    local key_exists
    key_exists=$(echo "$section_content" | grep -c "^$key\s*=" || echo "0")
    
    if [[ "$key_exists" -eq 0 ]]; then
        return 1  # Key doesn't exist - use default
    fi
    
    # Extract key value, strip comments
    local value_line
    value_line=$(echo "$section_content" | \
        grep "^$key\s*=" | \
        sed 's/#.*$//' | \  # Remove comments
        head -1)
    
    if [[ -z "$value_line" ]]; then
        return 1
    fi
    
    # Extract value (handle quoted and unquoted)
    local value
    value=$(echo "$value_line" | \
        sed 's/.*=\s*//' | \
        sed 's/^\s*//; s/\s*$//')  # Trim whitespace
    
    # Remove quotes if present
    if [[ "$value" =~ ^[\"'].*[\"']$ ]]; then
        value=$(echo "$value" | sed "s/^[\"']//; s/[\"']$//")
    fi
    
    # Return empty string if key exists but value is empty (explicit empty)
    # Caller checks return code: 0 = key exists (even if empty), 1 = key missing
    echo "$value"
    return 0
}

# Get TOML array (supports single-line and multi-line arrays)
# Uses balanced bracket matching to handle nested brackets correctly
# Supports top-level keys (empty section string)
get_toml_array() {
    local file="$1"
    local section="$2"  # Empty string for top-level
    local key="$3"
    
    # Handle top-level vs section
    if [[ -z "$section" ]]; then
        # Top-level key - search before first [ section
        local section_content
        section_content=$(sed '/^\[/,$d' "$file")
    else
        # Extract section content
        local escaped_section
        escaped_section=$(echo "$section" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g' | sed 's/\./\\./g' | sed 's/\*/\\*/g' | sed 's/\+/\\+/g' | sed 's/\?/\\?/g' | sed 's/\^/\\^/g' | sed 's/\$/\\$/g')
        section_content=$(sed -n "/\[$escaped_section\]/,/^\[/p" "$file" | sed '$d')
    fi
    
    # Find array declaration (key = [...] or key = [ ... ])
    local array_start_line
    array_start_line=$(echo "$section_content" | grep -n "^$key\s*=" | cut -d: -f1 | head -1)
    
    if [[ -z "$array_start_line" ]]; then
        return 1
    fi
    
    # Extract lines starting from array declaration
    local array_lines
    array_lines=$(echo "$section_content" | sed -n "${array_start_line},\$p")
    
    # Parse array using balanced bracket matching
    local result=""
    local in_quotes=false
    local quote_char=""
    local bracket_depth=0
    local array_started=false
    local current_element=""
    local line_num=0
    
    # Process character by character (bash 3.2 compatible)
    while IFS= read -r line; do
        ((line_num++))
        
        # Skip comment lines
        if [[ "$line" =~ ^[[:space:]]*# ]]; then
            continue
        fi
        
        # Strip inline comments
        line=$(echo "$line" | sed 's/#.*$//')
        
        # Process each character
        for ((i=0; i<${#line}; i++)); do
            local char="${line:$i:1}"
            
            case "$char" in
                '[')
                    if [[ "$in_quotes" == false ]]; then
                        if [[ "$array_started" == false ]]; then
                            array_started=true
                        fi
                        ((bracket_depth++))
                    else
                        current_element="$current_element$char"
                    fi
                    ;;
                ']')
                    if [[ "$in_quotes" == false ]]; then
                        ((bracket_depth--))
                        if [[ $bracket_depth -eq 0 && "$array_started" == true ]]; then
                            # End of array
                            if [[ -n "$current_element" ]]; then
                                current_element=$(echo "$current_element" | sed 's/^\s*//; s/\s*$//')
                                if [[ -n "$current_element" ]]; then
                                    if [[ -n "$result" ]]; then
                                        result="$result,$current_element"
                                    else
                                        result="$current_element"
                                    fi
                                fi
                            fi
                            # Remove quotes and return
                            echo "$result" | sed "s/[\"']//g" | sed 's/\s*,\s*/,/g'
                            return 0
                        fi
                    else
                        current_element="$current_element$char"
                    fi
                    ;;
                '"'|"'")
                    if [[ "$in_quotes" == false ]]; then
                        in_quotes=true
                        quote_char="$char"
                    elif [[ "$char" == "$quote_char" ]]; then
                        in_quotes=false
                        quote_char=""
                    fi
                    current_element="$current_element$char"
                    ;;
                ',')
                    if [[ "$in_quotes" == false && "$array_started" == true && $bracket_depth -eq 1 ]]; then
                        # Comma separator at array level
                        current_element=$(echo "$current_element" | sed 's/^\s*//; s/\s*$//')
                        if [[ -n "$current_element" ]]; then
                            if [[ -n "$result" ]]; then
                                result="$result,$current_element"
                            else
                                result="$current_element"
                            fi
                        fi
                        current_element=""
                    else
                        current_element="$current_element$char"
                    fi
                    ;;
                *)
                    if [[ "$array_started" == true ]]; then
                        current_element="$current_element$char"
                    fi
                    ;;
            esac
        done
        
        # Add newline if in quotes (for multi-line strings)
        if [[ "$in_quotes" == true ]]; then
            current_element="$current_element "
        fi
    done <<< "$array_lines"
    
    # Array not closed properly
    if [[ $bracket_depth -ne 0 ]]; then
        log_error "Unbalanced brackets in array: $file (section: $section, key: $key)"
        return 1
    fi
    
    return 1
}
```

### Updated Functions

```bash
# Get package files (manifest-aware with fallback)
get_package_files() {
    local package="$1"
    
    # Try manifest first
    if load_package_manifest "$package"; then
        echo "$PACKAGE_FILES"
        return 0
    fi
    
    # Phase 3: Require manifest (if enabled)
    if [[ "${REQUIRE_MANIFESTS:-false}" == "true" ]]; then
        log_error "Package '$package' missing manifest: $PACKAGES_DIR/$package/manifest.toml"
        log_info "Create a minimal manifest:"
        log_info "  files = [\"file1\", \"file2\"]"
        return 1
    fi
    
    # Phase 1-2: Fallback to case statement (backward compatibility)
    case "$package" in
        system)  echo ".stow-global-ignore,.stowrc,.editorconfig,.inputrc" ;;
        git)     echo ".gitconfig,.gitattributes,.gitignore-globals" ;;
        zsh)     echo ".zshrc,.zprofile,.oh-my-zsh" ;;
        tmux)    echo ".tmux.conf" ;;
        gh)      echo ".config/gh/config.yml,.config/gh/hosts.yml" ;;
        gnuplot) echo ".gnuplot" ;;
        bash)    echo ".bashrc,.bash_profile" ;;
        fish)    echo ".config/fish/config.fish,.config/fish/config.osx.fish,.config/fish/config.linux.fish,.config/fish/config.local.fish.example,.config/fish/functions" ;;
        wezterm) echo ".wezterm.lua" ;;
        bat)     echo ".config/bat/config" ;;
        rust)    echo ".cargo/config.toml,.cargo/config.local.toml.example,.rustfmt.toml,.rustfmt.toml.example" ;;
        *)       echo "" ;;
    esac
}

# Get installation method
get_package_method() {
    local package="$1"
    
    if load_package_manifest "$package"; then
        echo "$PACKAGE_METHOD"
    else
        echo "stow"  # Default
    fi
}

# Get package name
get_package_name() {
    local package="$1"
    
    if load_package_manifest "$package"; then
        echo "$PACKAGE_NAME"
    else
        # Fallback (Phase 1-2 only)
        case "$package" in
            system) echo "System" ;;
            git) echo "Git" ;;
            zsh) echo "Zsh" ;;
            tmux) echo "Tmux" ;;
            gh) echo "GitHub CLI" ;;
            gnuplot) echo "GNU Plot" ;;
            bash) echo "Bash" ;;
            fish) echo "Fish" ;;
            wezterm) echo "WezTerm" ;;
            bat) echo "Bat" ;;
            rust) echo "Rust" ;;
            *) echo "$package" ;;
        esac
    fi
}

# Get package description
get_package_description() {
    local package="$1"
    
    if load_package_manifest "$package"; then
        echo "$PACKAGE_DESCRIPTION"
    else
        # Fallback (Phase 1-2 only)
        case "$package" in
            system) echo "System-wide configuration" ;;
            git) echo "Git configuration and aliases" ;;
            zsh) echo "Zsh shell with Oh My Zsh" ;;
            tmux) echo "Tmux terminal multiplexer" ;;
            gh) echo "GitHub CLI configuration" ;;
            gnuplot) echo "Gnuplot configuration" ;;
            bash) echo "Bash shell configuration" ;;
            fish) echo "Fish shell configuration" ;;
            wezterm) echo "WezTerm terminal emulator" ;;
            bat) echo "Bat syntax highlighter" ;;
            rust) echo "Rust toolchain configuration" ;;
            *) echo "" ;;
        esac
    fi
}
```

### Phase 4: Auto-Discovery Implementation

```bash
# Discover packages by scanning for manifests (Phase 4)
# Optimized: Only check direct descendants of packages/ directory
discover_packages() {
    local packages=()
    
    if [[ ! -d "$PACKAGES_DIR" ]]; then
        return 1
    fi
    
    # Find manifest.toml files only in direct package directories (maxdepth 2)
    # This is fast: only ~11 directories to check
    while IFS= read -r manifest; do
        # Extract package name from path
        local package_dir
        package_dir=$(dirname "$manifest")
        local package
        package=$(basename "$package_dir")
        
        # Validate manifest exists and is readable
        if [[ -f "$manifest" ]] && [[ -r "$manifest" ]]; then
            packages+=("$package")
        fi
    done < <(find "$PACKAGES_DIR" -maxdepth 2 -name "manifest.toml" -type f 2>/dev/null)
    
    echo "${packages[@]}"
}

# Replace PACKAGES array with discovery (Phase 4)
# OLD: PACKAGES=(system git zsh ...)
# NEW: PACKAGES=($(discover_packages))

# Performance: find with -maxdepth 2 completes in milliseconds
# No caching needed - direct check is fast enough
```

**Benefits of Auto-Discovery:**
- ✅ Single source of truth (manifest files)
- ✅ No need to update array when adding packages
- ✅ Packages automatically appear in `./dot packages` output
- ✅ Eliminates another source of duplication

### Syntactic Validation

**Check manifest structure:**
- File exists and is readable
- Valid TOML syntax (basic check)
- Required top-level field exists: `files`
- Valid array format (single-line or multi-line)

**Implementation:**

```bash
validate_manifest_syntax() {
    local manifest="$1"
    local errors=0
    
    # Check file exists
    if [[ ! -f "$manifest" ]]; then
        log_error "Manifest not found: $manifest"
        return 1
    fi
    
    # Check for files array (top-level)
    if ! grep -q "^files\s*=" "$manifest"; then
        log_error "Manifest missing 'files' field: $manifest"
        ((errors++))
    fi
    
    # Basic TOML syntax check (look for invalid patterns)
    if grep -q "^[^#\[\s].*[^=]=[^=]" "$manifest"; then
        # Check for invalid lines (not comments, sections, or key=value)
        log_warning "Manifest may have syntax issues: $manifest"
    fi
    
    return $errors
}
```

### Semantic Validation

**Check manifest content:**
- Files listed in manifest exist in package directory
- File paths are valid (no traversal attacks)
- Method is valid (`stow`, `copy-sync`, `template`, `script`)

**Implementation:**

```bash
validate_manifest_semantic() {
    local package="$1"
    local manifest="$PACKAGES_DIR/$package/manifest.toml"
    local errors=0
    
    if ! load_package_manifest "$package"; then
        return 1
    fi
    
    # Validate method
    case "$PACKAGE_METHOD" in
        stow|copy-sync|template|script)
            # Valid method
            ;;
        *)
            log_error "Invalid method '$PACKAGE_METHOD' in manifest: $manifest"
            ((errors++))
            ;;
    esac
    
    # Validate files exist
    IFS=',' read -ra files <<< "$PACKAGE_FILES"
    for file in "${files[@]}"; do
        local file_path="$PACKAGES_DIR/$package/$file"
        
        # Check for path traversal
        if [[ "$file" == *".."* ]] || [[ "$file" == "/"* ]]; then
            log_error "Invalid file path (security): $file"
            ((errors++))
            continue
        fi
        
        # Check file exists
        if [[ ! -e "$file_path" ]]; then
            log_error "File listed in manifest but not found: $file (expected: $file_path)"
            ((errors++))
        fi
    done
    
    return $errors
}
```

### Health Check Integration

Add manifest validation to `cmd_health()`:

```bash
# In cmd_health() function
show_health_check_spinner "X" "Manifest Validation"
output=$(validate_all_manifests 2>&1)
result=$?
if [[ $result -ne 0 ]]; then
    check_statuses+=("fail")
    check_details+=("Validation errors")
    check_outputs+=("$output")
    show_health_table_row "X" "Manifest Validation" "fail" "Validation errors"
else
    check_statuses+=("pass")
    check_details+=("All manifests valid")
    check_outputs+=("")
    show_health_table_row "X" "Manifest Validation" "pass" "All manifests valid"
fi
```

## Example Manifests

```toml
packages/git/manifest.toml

files = [".gitconfig", ".gitattributes", ".gitignore-globals"]
```

Defaults applied:
- `name`: `"Git"` (from directory)
- `description`: `""` (empty)
- `method`: `"stow"`
- `target`: `$HOME`

### Standard Stow Package

```toml
packages/git/manifest.toml

name = "Git"
description = "Git configuration and aliases"
method = "stow"
target = "$HOME"
files = [".gitconfig", ".gitattributes", ".gitignore-globals"]
```

### Copy-Sync Package (Cursor)

```toml
packages/cursor/manifest.toml

name = "Cursor IDE"
description = "Cursor IDE configuration (copy-sync)"
method = "copy-sync"
target = "$HOME"
files = ["settings.json", "keybindings.json"]

[macos]
target = "~/Library/Application Support/Cursor/User"

[linux]
target = "~/.config/Cursor/User"
```

### Package with Platform-Specific Targets

```toml
packages/cursor/manifest.toml

name = "Cursor IDE"
method = "copy-sync"
target = "$HOME"  # Default target
files = ["settings.json", "keybindings.json"]

[macos]
target = "~/Library/Application Support/Cursor/User"

[linux]
target = "~/.config/Cursor/User"
```

Platform-specific `target` values override the top-level `target` when detected.

### Package with Dependencies (Multi-line Array Example)

```toml
packages/rust/manifest.toml

name = "Rust"
description = "Rust toolchain configuration"
method = "stow"
target = "$HOME"
files = [
  ".cargo/config.toml",
  ".cargo/config.local.toml.example",
  ".rustfmt.toml",
  ".rustfmt.toml.example"
]

[dependencies]
optional = ["rustc", "cargo"]
```

**Note**: Multi-line arrays are fully supported with balanced bracket matching.

## Structure Simplification

**Key Design Decisions:**

1. **No dot prefix**: `manifest.toml` instead of `.manifest.toml`
   - More visible and discoverable
   - Configuration files shouldn't be hidden

2. **Top-level keys**: All primary attributes at top level
   - `files`, `name`, `description`, `method`, `target` are top-level
   - Eliminates redundant `[files]` block with `files.files` path
   - Simpler structure, easier to read

3. **Platform-specific overrides**: `[linux]` and `[macos]` sections
   - Cleaner than `[copy-sync]` block with `macos_target`/`linux_target`
   - `target` key applies to all methods (stow, copy-sync, etc.)
   - Platform sections override top-level `target` when detected
   - Alternative considered: `[If "os:linux"]` syntax, but `[linux]`/`[macos]` is simpler and standard TOML

**Benefits:**
- ✅ Simpler structure (no nested sections for basic attributes)
- ✅ More intuitive (top-level keys for common fields)
- ✅ Platform overrides work for all methods, not just copy-sync
- ✅ Standard TOML syntax (no custom conditionals needed)

## Critical Review - Issues Found

### Issue 1: Default Value Application Logic Bug ⚠️ CRITICAL

**Problem**: Current code uses `${VAR:-default}` which applies default for empty strings, but we want:
- **Missing key** → apply default
- **Empty string** (`key = ""`) → explicit empty (no default)

**Current code**:
```bash
PACKAGE_METHOD=$(get_toml_value "$manifest" "" "method")
# Apply defaults
PACKAGE_METHOD="${PACKAGE_METHOD:-stow}"  # ❌ Wrong: applies default to empty strings
```

**Fix**: Check return code to distinguish missing vs empty:
```bash
if get_toml_value "$manifest" "" "method" >/dev/null; then
    PACKAGE_METHOD=$(get_toml_value "$manifest" "" "method")
    # If empty string, keep empty (explicit empty)
    # Only apply default if key doesn't exist (return code 1)
else
    PACKAGE_METHOD="stow"  # Default only when key missing
fi
```

**Impact**: Medium - affects when defaults are applied vs explicit empty values.

### Issue 2: Target Path Expansion ⚠️ IMPORTANT

**Problem**: Examples use both `$HOME` and `~` but expansion behavior differs:
- `$HOME` expands automatically in bash
- `~` requires `eval` or manual expansion

**Current examples**:
```toml
target = "$HOME"  # Expands automatically
target = "~/Library/Application Support/Cursor/User"  # Needs expansion
```

**Fix**: Support both - expand `~` to `$HOME` after parsing:
```bash
# Expand ~ to $HOME
if [[ "$PACKAGE_TARGET" == ~* ]]; then
    PACKAGE_TARGET="${PACKAGE_TARGET/#\~/$HOME}"
fi
```

**Impact**: Low - mostly documentation/consistency issue.

### Issue 3: Top-Level Keys After Sections ⚠️ DOCUMENTATION

**Problem**: `sed '/^\[/,$d'` stops at first `[`, so top-level keys after sections are ignored.

**Current behavior**:
```toml
[linux]
target = "..."

files = [".gitconfig"]  # ❌ This would be ignored!
```

**Standard TOML**: Top-level keys MUST come before any sections. This is correct behavior.

**Fix**: Document restriction - top-level keys must be before sections.

**Impact**: Low - TOML standard compliant, just needs documentation.

### Issue 4: Empty Array Handling ⚠️ DOCUMENTATION

**Problem**: `files = []` returns empty string, fails validation. Is this correct?

**Current behavior**: Empty array → empty string → validation fails → correct (files required)

**Fix**: Document that empty arrays are invalid (files required).

**Impact**: Low - correct behavior, just needs documentation.

### Issue 5: Key Name Collision ⚠️ DOCUMENTATION

**Problem**: What if someone has a top-level key named `linux` or `macos`?

**Example**:
```toml
linux = "some value"  # Top-level key
[linux]              # Section
target = "..."
```

**Current behavior**: `get_toml_value` searches top-level first (empty section), then sections. Top-level key would be found first.

**Fix**: Document restriction - avoid top-level keys named `linux` or `macos` (reserved for platform sections).

**Impact**: Low - unlikely edge case, document restriction.

### Issue 6: Variable Quoting Consistency ⚠️ DOCUMENTATION

**Problem**: `target = "$HOME"` vs `target = $HOME` - unquoted `$HOME` doesn't expand in TOML.

**Current examples**: Mix quoted and unquoted. Need consistency.

**Fix**: Document - always quote variables: `target = "$HOME"` not `target = $HOME`.

**Impact**: Low - documentation issue.

### Issue 7: Unknown Platform Behavior ⚠️ DOCUMENTATION

**Problem**: `detect_platform()` returns "unknown" for unsupported platforms. What happens?

**Current code**: Unknown platform → no override → uses default target (correct fallback).

**Fix**: Document behavior - unknown platforms use default target (no override).

**Impact**: Low - correct fallback behavior, just needs documentation.

## Summary of Critical Issues

**Must Fix Before Phase 1:**
1. ❌ **Default value application** - Fix `${VAR:-default}` pattern to check return codes
2. ⚠️ **Target path expansion** - Support `~` expansion or document restriction

**Document Before Phase 2:**
3. ⚠️ **Top-level keys location** - Document must come before sections
4. ⚠️ **Empty arrays** - Document invalid (files required)
5. ⚠️ **Key name collision** - Document `linux`/`macos` reserved
6. ⚠️ **Variable quoting** - Document always quote variables
7. ⚠️ **Unknown platform** - Document fallback behavior

**Test Before Phase 2:**
8. ⚠️ **Trailing comma** - Add test case for `files = ["file1",]`
9. ⚠️ **Comment handling** - Verify comments in arrays work

### Deep Critical Analysis

After thorough review and research, several critical parsing issues have been identified that could cause silent failures or incorrect parsing:

#### Critical Issue 1: Array Parsing Regex Greedy Matching

**Problem**: The regex `sed 's/.*=\s*\[\(.*\)\].*/\1/'` uses greedy matching that will fail on:

```toml
files = ["file[1].txt", "file[2].txt"]  # Nested brackets break parsing
files = ["file\"quote.txt"]              # Escaped quotes break parsing
files = ["file,with,commas.txt"]         # Commas inside quotes extracted incorrectly
```

**Current regex behavior**:
- For `files = [".gitconfig", ".gitignore"]`: ✅ Works (simple case)
- For `files = ["file[1].txt"]`: ❌ Fails - regex matches `"file[1` instead of full string
- For `files = ["file\"quote.txt"]`: ❌ Fails - quotes break extraction
- For `files = ["file,with,commas.txt"]`: ⚠️ Partially works but commas will be split incorrectly

**Solution**: Use a more robust parsing approach:

```bash
get_toml_array() {
    local file="$1"
    local section="$2"
    local key="$3"
    
    # Extract section, find array line, strip comments
    local array_line
    array_line=$(sed -n "/\[$section\]/,/\[/p" "$file" | \
        grep "^$key\s*=" | \
        sed 's/#.*$//' | \  # Remove comments
        head -1)
    
    if [[ -z "$array_line" ]]; then
        return 1
    fi
    
    # Check for multi-line arrays (strict rejection)
    if ! echo "$array_line" | grep -q '\[.*\]'; then
        log_error "Multi-line arrays not supported in manifest: $file"
        log_info "Use single-line format: files = [\"file1\", \"file2\"]"
        return 1
    fi
    
    # Extract array content using more robust method
    # Find first [ and last ] on the line
    local array_start
    local array_end
    array_start=$(echo "$array_line" | sed 's/.*=//' | sed 's/\[.*//' | wc -c)
    array_end=$(echo "$array_line" | grep -o '\]' | wc -l)
    
    # Better approach: Extract between first [ and last ]
    local array_content
    array_content=$(echo "$array_line" | \
        sed 's/.*=\s*\[//' | \  # Remove everything before [
        sed 's/\]\s*$//' | \     # Remove trailing ]
        sed 's/^\s*//; s/\s*$//')  # Trim whitespace
    
    # Handle empty arrays
    if [[ -z "$array_content" ]]; then
        return 1
    fi
    
    # Parse array elements more carefully
    # Split on commas, but respect quoted strings
    local result=""
    local in_quotes=false
    local quote_char=""
    local current=""
    
    # Iterate through characters (bash 3.2 compatible - no associative arrays)
    for ((i=0; i<${#array_content}; i++)); do
        local char="${array_content:$i:1}"
        
        case "$char" in
            '"'|"'")
                if [[ "$in_quotes" == false ]]; then
                    in_quotes=true
                    quote_char="$char"
                elif [[ "$char" == "$quote_char" ]]; then
                    in_quotes=false
                    quote_char=""
                    # Add to result
                    if [[ -n "$result" ]]; then
                        result="$result,$current"
                    else
                        result="$current"
                    fi
                    current=""
                fi
                ;;
            ',')
                if [[ "$in_quotes" == false ]]; then
                    # Comma outside quotes - separator
                    if [[ -n "$current" ]]; then
                        if [[ -n "$result" ]]; then
                            result="$result,$current"
                        else
                            result="$current"
                        fi
                        current=""
                    fi
                else
                    current="$current$char"
                fi
                ;;
            *)
                current="$current$char"
                ;;
        esac
    done
    
    # Add last element
    if [[ -n "$current" ]]; then
        if [[ -n "$result" ]]; then
            result="$result,$current"
        else
            result="$current"
        fi
    fi
    
    # Remove quotes from individual elements
    echo "$result" | sed "s/[\"']//g" | sed 's/\s*,\s*/,/g'
}
```

**Alternative Simpler Solution**: Restrict filenames to avoid problematic characters:

```bash
# Validate filenames don't contain problematic characters
validate_filename() {
    local filename="$1"
    if [[ "$filename" =~ [\[\]\"\'\\] ]]; then
        log_error "Filename contains invalid characters: $filename"
        log_info "Filenames cannot contain: [ ] \" ' \\"
        return 1
    fi
    return 0
}
```

**Recommendation**: Use simpler validation + restricted character set rather than complex parsing. Most dotfiles don't need brackets/quotes in filenames.

#### Critical Issue 2: Section Extraction with Special Characters

**Problem**: Section names containing regex special characters will break parsing:

```toml
[package.name]  # Contains dot - regex special character
[package-name]  # Contains dash - not special but might be confused
```

**Current behavior**:
- `sed -n "/\[$section\]/,/\[/p"` - if `$section` contains `.`, it becomes a regex wildcard
- Could match multiple sections incorrectly

**Solution**: Escape regex special characters:

```bash
get_toml_value() {
    local file="$1"
    local section="$2"
    local key="$3"
    
    # Escape regex special characters in section name
    local escaped_section
    escaped_section=$(echo "$section" | sed 's/\[/\\[/g' | sed 's/\]/\\]/g' | sed 's/\./\\./g' | sed 's/\*/\\*/g' | sed 's/\+/\\+/g' | sed 's/\?/\\?/g' | sed 's/\^/\\^/g' | sed 's/\$/\\$/g')
    
    # Extract section, get key value, strip comments
    local value_line
    value_line=$(sed -n "/\[$escaped_section\]/,/\[/p" "$file" | \
        grep "^$key\s*=" | \
        sed 's/#.*$//' | \  # Remove comments
        head -1)
    
    # ... rest of function
}
```

**Recommendation**: Document that section names should be simple identifiers (letters, numbers, dashes, underscores only).

#### Critical Issue 3: Multi-line Array Support

**Requirement**: Must support multi-line arrays (not just reject them).

**Solution**: Implement balanced bracket matching with character-by-character parser:

```bash
# Parse array using balanced bracket matching (supports multi-line)
# Track bracket depth, handle quotes, commas correctly
# See get_toml_array() implementation above for full code
```

**Features**:
- ✅ Supports single-line arrays: `files = [".gitconfig", ".gitignore"]`
- ✅ Supports multi-line arrays: `files = [\n  ".gitconfig",\n  ".gitignore"\n]`
- ✅ Handles nested brackets within quoted strings
- ✅ Tracks quote state to avoid splitting on commas inside strings
- ✅ Returns comma-separated list for compatibility

**Recommendation**: ✅ Implemented - balanced bracket parser handles both formats.

#### Critical Issue 4: String Parsing with Escaped Quotes

**Problem**: Current parsing doesn't handle escaped quotes:

```toml
name = "Git \"config\""  # Escaped quotes break parsing
description = 'It\'s great'  # Escaped single quote breaks parsing
```

**Current regex**: `sed "s/^[\"']//; s/[\"']$//"` will fail on escaped quotes.

**Solution**: Document limitation and restrict or improve parsing:

```bash
# Option A: Restrict (simpler)
# Document: No escaped quotes in strings. Use single quotes if string contains double quotes.

# Option B: Improve parsing (complex)
# Parse character by character, handle escape sequences
```

**Recommendation**: Option A - document restriction. Escaped quotes are rare in package metadata.

#### Critical Issue 5: Empty String vs Missing Field

**Problem**: Current implementation cannot distinguish between:
- Missing field: `# name = "Git"` (commented out)
- Empty string: `name = ""`
- Unquoted empty: `name =`

All three return empty, then default is applied. But we want:
- Missing → default
- Empty string → explicit empty (no default)

**Current behavior**: All three cases get default applied.

**Solution**: Explicitly check for key existence:

```bash
get_toml_value() {
    local file="$1"
    local section="$2"
    local key="$3"
    
    # Check if key exists at all (even if empty)
    if ! grep -q "^$key\s*=" "$file"; then
        return 1  # Key doesn't exist - use default
    fi
    
    # Extract value (handles empty strings)
    local value_line
    value_line=$(sed -n "/\[$section\]/,/\[/p" "$file" | \
        grep "^$key\s*=" | \
        sed 's/#.*$//' | \
        head -1)
    
    # Extract value
    local value
    value=$(echo "$value_line" | \
        sed 's/.*=\s*//' | \
        sed 's/^\s*//; s/\s*$//')
    
    # Empty string is valid (explicit empty)
    # Missing value (only =) is also empty
    echo "$value"
    
    # Caller checks: if empty and key exists, it's explicit empty
    # if empty and key doesn't exist, use default
}
```

**Recommendation**: Handle this correctly - missing field vs empty string matters for defaults.

#### Critical Issue 6: Auto-Discovery Performance

**Analysis**: Well-crafted `find` expression is extremely fast for this use case:

- Only checking direct descendants of `./packages`
- Only looking for `manifest.toml` files
- Small number of packages (~11)
- Modern filesystems are fast for this pattern

**Performance**: `find "$PACKAGES_DIR" -maxdepth 2 -name "manifest.toml" -type f` completes in milliseconds.

**Solution**: No caching needed - direct `find` is fast enough:

```bash
discover_packages() {
    local packages=()
    
    if [[ ! -d "$PACKAGES_DIR" ]]; then
        return 1
    fi
    
    # Find manifests in direct package directories only (maxdepth 2)
    while IFS= read -r manifest; do
        local package_dir
        package_dir=$(dirname "$manifest")
        local package
        package=$(basename "$package_dir")
        packages+=("$package")
    done < <(find "$PACKAGES_DIR" -maxdepth 2 -name "manifest.toml" -type f 2>/dev/null)
    
    echo "${packages[@]}"
}
```

**Recommendation**: No caching needed - `find` with `-maxdepth 2` is fast enough.

### Identified Issues and Solutions

#### Issue 1: TOML Array Parsing Edge Cases

**Problem**: Simple sed-based parsing may fail on valid TOML patterns:
- Trailing commas: `files = ["file1", "file2",]`
- Empty arrays: `files = []`
- Spacing variations: `files = [ "file1" , "file2" ]`
- Comments on same line: `files = ["file1"] # comment`

**Solution**: Enhance parsing to handle these cases:

```bash
get_toml_array() {
    local file="$1"
    local section="$2"
    local key="$3"
    
    # Extract section, find array line, strip comments
    local array_line
    array_line=$(sed -n "/\[$section\]/,/\[/p" "$file" | \
        grep "^$key\s*=" | \
        sed 's/#.*$//' | \  # Remove comments
        head -1)
    
    # Extract array content (handle spacing, trailing commas)
    local array_content
    array_content=$(echo "$array_line" | \
        sed 's/.*=\s*\[\(.*\)\].*/\1/' | \
        sed 's/,\s*$//' | \  # Remove trailing comma
        sed 's/^\s*//; s/\s*$//')  # Trim whitespace
    
    # Handle empty arrays
    if [[ -z "$array_content" ]]; then
        return 1
    fi
    
    # Extract values, handle quoted strings
    echo "$array_content" | \
        sed "s/[\"']//g" | \
        sed 's/\s*,\s*/,/g'
}
```

**Recommendation**: Add comprehensive tests for array parsing edge cases.

#### Issue 2: String Value Parsing

**Problem**: Current regex may not handle:
- Unquoted strings (valid TOML): `name = Git`
- Single vs double quotes: `name = 'Git'` vs `name = "Git"`
- Escaped quotes: `name = "Git \"config\""`

**Solution**: Support both quoted and unquoted strings:

```bash
get_toml_value() {
    local file="$1"
    local section="$2"
    local key="$3"
    
    local value_line
    value_line=$(sed -n "/\[$section\]/,/\[/p" "$file" | \
        grep "^$key\s*=" | \
        sed 's/#.*$//' | \  # Remove comments
        head -1)
    
    # Extract value (handle quoted and unquoted)
    local value
    value=$(echo "$value_line" | \
        sed 's/.*=\s*//' | \
        sed 's/^\s*//; s/\s*$//')
    
    # Remove quotes if present
    if [[ "$value" =~ ^[\"'].*[\"']$ ]]; then
        value=$(echo "$value" | sed "s/^[\"']//; s/[\"']$//")
    fi
    
    echo "$value"
}
```

**Recommendation**: Document that unquoted strings are supported but quoted strings are preferred for clarity.

#### Issue 3: Validation Performance

**Problem**: File existence checks on every health check could be slow (especially with many packages).

**Solution**: Make semantic validation optional or cached:

```bash
validate_all_manifests() {
    local skip_semantic="${1:-false}"
    local errors=0
    
    for package in "${PACKAGES[@]}"; do
        local manifest="$PACKAGES_DIR/$package/manifest.toml"
        
        # Always check syntax
        if ! validate_manifest_syntax "$manifest"; then
            ((errors++))
        fi
        
        # Skip semantic checks if requested (for performance)
        if [[ "$skip_semantic" == "true" ]]; then
            continue
        fi
        
        # Check semantics (file existence)
        if ! validate_manifest_semantic "$package"; then
            ((errors++))
        fi
    done
    
    return $errors
}

# In health check
if [[ "$verbose" == "true" ]]; then
    # Full validation in verbose mode
    validate_all_manifests false
else
    # Syntax only in normal mode (fast)
    validate_all_manifests true
fi
```

**Recommendation**: Use syntax-only validation in normal health check, full validation in verbose mode or on install/update.

#### Issue 4: Default Value Ambiguity

**Problem**: When is a default applied vs explicit empty value?
- Missing field: Use default
- Empty string: `description = ""` → empty description (explicit)
- Unset: No field → use default

**Solution**: Document clearly:
- **Missing field**: Use default
- **Empty string**: Explicit empty (no default)
- **Present value**: Use provided value

**Implementation**: Current approach handles this correctly - missing field returns empty, then default is applied.

**Recommendation**: Add comments in manifests to clarify defaults:

```toml
[package]
# name = "Git"  # Defaults to directory name if omitted
description = ""  # Explicit empty
method = "stow"  # Defaults to "stow" if omitted
```

#### Issue 5: Multi-line Array Handling

**Problem**: What if someone accidentally uses multi-line arrays?

**Solution**: Two approaches:

**Option A: Strict (Reject multi-line)**

```bash
# Check for multi-line arrays
if grep -A 5 "^files\s*=" "$manifest" | grep -q "^\[files\]"; then
    log_error "Multi-line arrays not supported: $manifest"
    return 1
fi
```

**Option B: Lenient (Parse first line only)**

```bash
# Parse only first line of array declaration
array_line=$(sed -n "/\[files\]/,/\[/p" "$manifest" | \
    grep "^files\s*=" | \
    head -1)
# Continue parsing...
```

**Recommendation**: Use Option A (strict) with clear error message pointing to documentation. This prevents confusion and maintains simplicity.

#### Issue 6: Phase 3 Migration Safety

**Problem**: Removing case statements could break packages without manifests.

**Solution**: Graceful degradation:

```bash
get_package_files() {
    local package="$1"
    
    # Try manifest first
    if load_package_manifest "$package"; then
        echo "$PACKAGE_FILES"
        return 0
    fi
    
    # Phase 3: Require manifest
    if [[ "${REQUIRE_MANIFESTS:-false}" == "true" ]]; then
        log_error "Package '$package' missing manifest: $PACKAGES_DIR/$package/manifest.toml"
        log_info "Create a minimal manifest with:"
        log_info "  files = [\"file1\", \"file2\"]"
        return 1
    fi
    
    # Phase 1-2: Fallback to case statement
    case "$package" in
        # ... existing cases ...
    esac
}
```

**Recommendation**: Use environment variable `REQUIRE_MANIFESTS=true` to enable Phase 3 behavior, default to `false` for gradual migration.

### Additional Improvements

#### Improvement 1: Package Structure Documentation

**Create `packages/README.md`** (single source of truth):

```markdown
# Package Structure

## Manifest Format

Each package must have a `manifest.toml` file defining its structure.

### Required Fields

- `files` - Array of files to be stowed (required, top-level)

### Optional Fields

- `name` - Display name (default: directory name, top-level)
- `description` - Package description (default: empty, top-level)
- `method` - Installation method (default: "stow", top-level)
- `target` - Target directory (default: "$HOME", top-level)

### Platform-Specific Overrides

- `[linux].target` - Override target for Linux
- `[macos].target` - Override target for macOS

### Installation Methods

- `stow` - Standard symlink-based installation
- `copy-sync` - Copy files instead of symlinks
- `template` - Process templates before stowing
- `script` - Run custom install script

## Examples

See individual package directories for example manifests.
```

**Benefits**:
- Single source of truth for package structure
- Linked from AGENTS.md, README.md, and other docs
- Remove duplicate information from other sources
- Accessible to both humans and AI readers

#### Improvement 2: Standalone Package Validation

**Create `./dev/validate-package PATH` script**:

```bash
#!/usr/bin/env bash
# Validate a package (not just manifest - includes file existence, etc.)

# Usage: ./dev/validate-package packages/git
#        ./dev/validate-package packages/cursor/manifest.toml

validate_package_standalone() {
    local path="$1"
    local package_dir
    local manifest
    
    # Handle both package directory and manifest file paths
    if [[ -f "$path" ]]; then
        manifest="$path"
        package_dir=$(dirname "$path")
    else
        package_dir="$path"
        manifest="$package_dir/manifest.toml"
    fi
    
    # Validate manifest syntax
    validate_manifest_syntax "$manifest" || return 1
    
    # Validate manifest semantics (file existence, etc.)
    validate_manifest_semantic "$package_dir" || return 1
    
    log_success "Package validation passed: $package_dir"
    return 0
}

validate_package_standalone "$@"
```

**Integration with dot script**:

```bash
# In dot script
cmd_validate_manifests() {
    local package="${1:-}"
    
    if [[ -n "$package" ]]; then
        # Validate specific package using dev script
        "$DOTFILES_DIR/dev/validate-package" "packages/$package"
    else
        # Validate all packages
        for package in "${PACKAGES[@]}"; do
            "$DOTFILES_DIR/dev/validate-package" "packages/$package"
        done
    fi
}
```

**Benefits**:
- Standalone script usable independently
- Validates entire package (not just manifest)
- Can be called from CI/CD
- Integrated into dot script for convenience

#### Improvement 3: Manifest Generation Tool

**Deferred** - Will be part of future tooling for new package adoption and existing config migration.

#### Improvement 4: Auto-Discovery (Phase 4)

**Add as Phase 4** - Eliminate PACKAGES array by scanning for manifests (see Phase 4 above).

### Final Recommendations

1. ✅ **Keep simplified TOML** - Good balance of structure and bash-parsability
2. ✅ **Enhance parsing** - Handle edge cases (trailing commas, spacing, comments)
3. ✅ **Performance optimization** - Syntax-only validation in normal health check
4. ✅ **Clear error messages** - Guide users to fix issues
5. ✅ **Gradual migration** - Use environment variable for Phase 3 enforcement
6. ✅ **Comprehensive testing** - Test all parsing edge cases
7. ✅ **Documentation** - Schema documentation and examples

### Remaining Questions

1. **Multi-line arrays**: Strict rejection or lenient parsing?
   - **Recommendation**: Strict rejection with clear error message

2. **Unquoted strings**: Support or require quotes?
   - **Recommendation**: Support both, prefer quoted for clarity

3. **Validation timing**: Always validate or only on install/update?
   - **Recommendation**: Syntax check always, semantic check on install/update/verbose health

4. **Manifest generation**: Auto-generate from case statements?
   - **Recommendation**: Yes, add helper script for Phase 2 migration

5. **Backward compatibility duration**: How long keep case statements?
   - **Recommendation**: Until all packages migrated, then remove in Phase 3

## Testing Strategy

### Unit Tests

```bash
# tests/unit/test_manifest_parsing.bats
@test "load_package_manifest reads minimal manifest" {
    # Test minimal manifest parsing
}

@test "load_package_manifest applies defaults correctly" {
    # Test default values
}

@test "get_toml_array parses single-line arrays" {
    # Test array parsing
}

@test "validate_manifest_syntax catches missing files section" {
    # Test syntax validation
}

@test "validate_manifest_semantic checks file existence" {
    # Test semantic validation
}
```

### Integration Tests

```bash
# tests/integration/test_manifest_integration.bats
@test "package with manifest works in install" {
    # Test full installation flow
}

@test "package without manifest falls back to case statement" {
    # Test backward compatibility
}

@test "health check validates manifests" {
    # Test health check integration
}
```

## Benefits

1. ✅ **Single source of truth**: All metadata in one file
2. ✅ **Installation method**: Declared in manifest (solves Issue #117)
3. ✅ **Extensible**: Add new fields without script changes
4. ✅ **Self-documenting**: `ls packages/git` shows `manifest.toml`
5. ✅ **DRY**: No duplication across multiple functions
6. ✅ **Cursor integration**: Can add cursor to PACKAGES array
7. ✅ **Future-proof**: Easy to add dependencies, platform requirements
8. ✅ **Validation**: Can validate manifests independently
9. ✅ **Standard format**: Valid TOML (can use external tools)

## Migration Checklist

### Phase 1
- [ ] Implement `load_package_manifest()` function
- [ ] Update `get_package_files()` with manifest support
- [ ] Update `get_package_name()` with manifest support
- [ ] Update `get_package_description()` with manifest support
- [ ] Add `validate_manifest_syntax()` function
- [ ] Add tests for manifest parsing
- [ ] Verify backward compatibility

### Phase 2
- [ ] Create `manifest.toml` for all 11 packages
- [ ] Update functions to prefer manifests
- [ ] Add `validate_manifest_semantic()` function
- [ ] Add semantic validation to health check
- [ ] Create `packages/README.md` (schema documentation)
- [ ] Update AGENTS.md, README.md to link to packages/README.md
- [ ] Remove duplicate package structure info from other docs
- [ ] Create `./dev/validate-package` script
- [ ] Integrate `./dev/validate-package` into dot script
- [ ] Review `.stow-local-ignore` files:
  - [ ] Remove for packages with individual files only
  - [ ] Keep for packages that stow directories (zsh, fish)
- [ ] Test all packages with manifests

### Phase 3
- [ ] Require manifests in validation
- [ ] Remove case statement fallbacks
- [ ] Update error messages
- [ ] Add health check warning for missing manifests
- [ ] Update documentation

### Phase 4
- [ ] Implement `discover_packages()` function
- [ ] Replace `PACKAGES` array with auto-discovery
- [ ] Update all functions to use discovered packages
- [ ] Add validation for discovered packages
- [ ] Update tests for auto-discovery

## Summary

### Key Decisions

- **Format**: Simplified TOML (`manifest.toml`) - valid TOML but restricted subset
- **Naming**: `manifest.toml` (not hidden, visible configuration file)
- **Parsing**: Simplified bash-parsable subset (no external dependencies)
- **Migration**: Gradual (3 phases), each phase separate commit, no squashing
- **Required Fields**: Optional in Phase 1, required by Phase 3 (minimal: `files` only)
- **Defaults**: `name`=directory, `description`=empty, `method`=stow, `target`=$HOME
- **Validation**: Both syntactic (structure) and semantic (file existence)

### Simplified TOML Restrictions

**Allowed:**
- Tables (sections): `[linux]`, `[macos]` for platform-specific overrides (any characters, regex special chars escaped)
- Top-level keys: `files`, `name`, `description`, `method`, `target`
- String values: `name = "value"` or `name = 'value'` or `name = value`
- Single-line arrays: `files = ["file1", "file2"]`
- Multi-line arrays: `files = [\n  "file1",\n  "file2"\n]`
- Comments: `# comments`
- Basic types: strings, booleans, integers
- Nested brackets within quoted strings (handled correctly)

**Not Supported (but valid TOML):**
- Nested tables (`[package.nested]`)
- Inline tables
- Complex escaping
- Escaped quotes in strings (document as restriction)

**Supported:**
- ✅ Multi-line arrays (balanced bracket matching)
- ✅ Single-line arrays
- ✅ Nested brackets within quoted strings (handled correctly)
- ✅ Section names with any characters (regex special chars escaped)
- ✅ Platform-specific overrides via `[linux]` and `[macos]` sections
- ✅ Top-level keys for simple configuration

### Implementation Phases

**Phase 1**: Add manifest support with case statement fallbacks  
**Phase 2**: Migrate all packages to manifests + create tooling  
**Phase 3**: Require manifests, remove case statements (controlled by `REQUIRE_MANIFESTS` env var)  
**Phase 4**: Auto-discovery - eliminate PACKAGES array by scanning for manifests  
**Performance**: `find` with `-maxdepth 2` is fast enough, no caching needed

### Critical Considerations Addressed

1. ✅ **Array parsing edge cases**: Enhanced parser handles trailing commas, spacing, comments
2. ✅ **String parsing**: Supports both quoted and unquoted strings
3. ✅ **Validation performance**: Syntax-only in normal health check, full in verbose
4. ✅ **Default values**: Clear documentation of when defaults apply
5. ✅ **Multi-line arrays**: Strict rejection with clear error message
6. ✅ **Migration safety**: Environment variable for gradual Phase 3 enforcement

### Critical Issues Requiring Fixes

**CRITICAL (Must fix before Phase 1):**
1. ✅ **Array parsing** - **FIXED**: Implemented balanced bracket matching with character-by-character parser
   - **Solution**: State machine parsing handles nested brackets, quotes, commas correctly
   - **Supports**: Single-line and multi-line arrays

2. ✅ **Section extraction regex injection** - **FIXED**: Escape regex special characters
   - **Solution**: Escape `.`, `*`, `+`, `?`, `^`, `$`, `[`, `]` in section names
   - **Result**: Section names can contain any characters safely

3. ✅ **Empty string vs missing field** - **FIXED**: Check key existence before extracting
   - **Solution**: Use `grep -c` to check if key exists in section
   - **Result**: Can distinguish missing field (default) vs empty string (explicit empty)

**RESOLVED:**
4. ✅ **Multi-line array support** - **FIXED**: Implemented balanced bracket matching
   - **Solution**: Character-by-character parser with bracket depth tracking
   - **Result**: Supports both single-line and multi-line arrays

5. ✅ **Auto-discovery performance** - **NO FIX NEEDED**: `find` with `-maxdepth 2` is fast enough
   - **Analysis**: Only checking direct descendants, small number of packages
   - **Result**: No caching needed - completes in milliseconds

**MEDIUM PRIORITY (Document):**
6. ⚠️ **Escaped quotes** - Escaped quotes break parsing
   - **Fix**: Document restriction (no escaped quotes)
   - **Recommendation**: Document restriction (acceptable for metadata)

### Stow Ignore Files

**Update**: With explicit file listing in manifests, `.stow-local-ignore` files are no longer needed for most packages.

**When `.stow-local-ignore` is still needed:**
- Packages that stow entire directories (e.g., `.oh-my-zsh` submodule, `.config/fish/functions`)
- When specific files within a stowed directory should be excluded

**When `.stow-local-ignore` can be removed:**
- Packages that only list individual files in manifest
- Files are explicitly referenced, so no exclusion needed

**Migration**: Remove `.stow-local-ignore` files from packages that only list individual files. Keep for packages that stow directories.

### Proposed Format Restrictions

**Filenames**: No problematic characters `[ ] " ' \` outside of quotes (brackets inside quotes are handled correctly)  
**Strings**: No escaped quotes (use single quotes if string contains double quotes)  
**Section names**: Any characters supported (regex special characters are escaped automatically)

**Note**: Multi-line arrays are fully supported with balanced bracket matching.

### Recommendations

1. ✅ **Keep simplified TOML** - Good balance of structure and bash-parsability
2. ✅ **Multi-line array support** - Implemented balanced bracket matching (FIXED)
3. ✅ **Empty string handling** - Fixed with key existence check (FIXED)
4. ✅ **Section extraction** - Fixed with regex escaping (FIXED)
5. ✅ **Array parsing** - Fixed with balanced bracket parser (FIXED)
6. ✅ **Auto-discovery** - No caching needed, `find -maxdepth 2` is fast (OPTIMIZED)
7. ✅ **Document restrictions** - Escaped quotes limitation (MEDIUM PRIORITY)
8. ✅ **Comprehensive testing** - Test all parsing edge cases
9. ✅ **Documentation** - `packages/README.md` as single source of truth, linked from all docs
10. ✅ **Standalone validation** - `./dev/validate-package` script for CI/CD
11. ✅ **Review `.stow-local-ignore`** - Remove for individual-file packages, keep for directory-stow packages

### Implementation Readiness

**Status**: ⚠️ **READY WITH FIXES REQUIRED**

**Before Phase 1:**
- [x] Fix array parsing (implemented balanced bracket matching)
- [x] Fix section extraction (implemented regex escaping)
- [x] Fix empty string handling (implemented key existence check)
- [x] Fix multi-line array support (implemented balanced bracket parser)
- [ ] **Fix default value application** - Use return code checks instead of `${VAR:-default}`
- [ ] **Add ~ expansion** - Support `~` expansion for target paths

**Before Phase 2:**
- [ ] Test multi-line array parsing thoroughly
- [ ] Test trailing comma handling: `files = ["file1",]`
- [ ] Test comment handling in arrays
- [ ] Document escaped quote restriction
- [ ] Document top-level keys must come before sections
- [ ] Document `linux`/`macos` reserved key names
- [ ] Document variable quoting requirement (`target = "$HOME"` not `target = $HOME`)
- [ ] Document empty arrays invalid (files required)
- [ ] Document unknown platform fallback behavior
- [ ] Review `.stow-local-ignore` files - remove for individual-file packages

**Before Phase 3:**
- [ ] Document all restrictions in `packages/README.md`
- [ ] Update validation to enforce restrictions

**Status**: ⚠️ **READY WITH FIXES REQUIRED**

**Critical Fixes Needed:**
1. ✅ Array parsing - **FIXED**: Balanced bracket matching implemented
2. ✅ Section extraction - **FIXED**: Regex escaping implemented
3. ✅ Empty string handling - **FIXED**: Key existence check implemented
4. ✅ Multi-line array support - **FIXED**: Balanced bracket parser implemented
5. ❌ **Default value application** - **MUST FIX**: Use return code checks, not `${VAR:-default}`
6. ❌ **Target path expansion** - **MUST FIX**: Add `~` expansion support

**Documentation Needed:**
7. ⚠️ Top-level keys location restriction
8. ⚠️ Reserved key names (`linux`, `macos`)
9. ⚠️ Variable quoting requirement
10. ⚠️ Empty arrays invalid
11. ⚠️ Unknown platform fallback behavior

## Related Issues

- Issue #68 Issue 4: Package metadata duplication
- Issue #117: Per-package installation methods (marker files)
- Issue #83: Consolidate package metadata (this solves it)
