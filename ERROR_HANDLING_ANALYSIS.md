# Error Handling Issues in dot Script

## Current Problems

### 1. Global `set -e` is Dangerous

**Issue:**

```bash
set -e  # Exit on any error
```

**Problems:**

- Exits immediately without cleanup
- No opportunity to handle errors gracefully
- Partial installations leave system in broken state
- Difficult to debug what went wrong

**Example failure scenario:**

```bash
# If stow fails halfway through:
stow git    # ✓ Success
stow zsh    # ✗ Fails - script exits immediately
stow tmux   # Never runs
# System left with partial install, no cleanup
```

---

### 2. No Trap Handlers

**Issue:** No cleanup on exit/error/interrupt.

**Problems:**

- Temporary files not cleaned
- Partial configs not rolled back
- No status reporting on failure
- Can't restore from backup automatically

**Recommended:**

```bash
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Installation failed with exit code $exit_code"
        # Cleanup logic here
    fi
}

trap cleanup EXIT
trap 'log_error "Script interrupted"; exit 130' INT TERM
```

---

### 3. Toggling `set +e` / `set -e` is Fragile

**Issue:** Manually toggling error handling:

```bash
set +e  # Disable
# ... code ...
set -e  # Re-enable (might be skipped if error occurs)
```

**Problems:**

- Easy to forget to re-enable
- Doesn't work well with returns/exits
- Makes code harder to follow
- Error-prone during refactoring

**Better approach:**

```bash
# Use explicit error checking
if ! some_command; then
    log_error "Command failed"
    return 1
fi
```

---

### 4. Process Substitution Can Hang

**Issue:** Current code uses process substitution:

```bash
while read -r line; do
    # ...
done < <(git config --list)  # Can hang if git fails
```

**Problems:**

- Subshells can block indefinitely
- Hard to timeout
- Errors in subshell not propagated well
- `set -e` doesn't work across process substitution

**Solution:**

```bash
# Use temporary variables or arrays
local config_output
config_output=$(git config --list 2>&1) || {
    log_error "Failed to read git config: $config_output"
    return 1
}

while read -r line; do
    # ... process ...
done <<< "$config_output"
```

---

### 5. Silent Failures in Subshells

**Issue:** Variable modifications in piped while loops don't propagate:

```bash
local count=0
find ... | while read file; do
    ((count++))  # This increment is lost!
done
echo "$count"  # Always 0
```

**Current workaround:** Check file existence after loop
**Better:** Use arrays or command substitution

---

### 6. No Error Context

**Issue:** Generic errors without context:

```bash
log_error "Validation failed"  # Which validation? Why?
```

**Better:**

```bash
log_error "Git validation failed: .gitconfig symlink points to wrong location"
log_error "Expected: .dotfiles/git/.gitconfig"  
log_error "Found: /tmp/gitconfig"
```

---

### 7. No Rollback Capability

**Issue:** If installation fails partway, no automatic recovery.

**Needed:**

- Track what was installed
- Rollback on error
- Restore from backup automatically
- Report what needs manual intervention

---

### 8. Missing Timeout Handling

**Issue:** No timeouts on potentially long operations:

- `curl` downloads
- `git submodule update`
- `find` operations
- `stow` operations

**Solution:**

```bash
timeout 30 curl -s "$url" > file || {
    log_error "Download timed out after 30s"
    return 1
}
```

---

### 9. No Dry-Run Mode

**Issue:** Can't preview what will happen without actually doing it.

**Needed:**

```bash
DRY_RUN=false

run_command() {
    if $DRY_RUN; then
        log_info "[DRY-RUN] Would run: $*"
    else
        "$@"
    fi
}
```

---

### 10. Exit vs Return Confusion

**Issue:** Mix of `exit` and `return` in functions:

- `exit` terminates entire script
- `return` exits function
- Inconsistent usage makes behavior unpredictable

**Better:** Always use `return` in functions, `exit` only in main()

---

## Recommendations

### High Priority

1. **Add trap handlers** for cleanup
2. **Replace `set -e`** with explicit error checking
3. **Add error context** to all error messages
4. **Fix process substitution** in `merge_git_config`
5. **Add timeout handling** for network operations

### Medium Priority

1. **Implement rollback** on installation failure
2. **Add dry-run mode** for safe previews
3. **Standardize exit/return** usage
4. **Add debug mode** with stack traces

### Low Priority

1. **Add retry logic** for network operations
2. **Validate inputs** before operations
3. **Add progress indicators** for long operations
4. **Create error recovery guide**

---

## Implementation Strategy

### Phase 1: Safe Error Handling

```bash
#!/bin/bash
# Remove: set -e

# Add cleanup trap
cleanup_on_error() {
    local exit_code=$?
    if [[ $exit_code -ne 0 && $exit_code -ne 130 ]]; then
        log_error "Script failed with exit code $exit_code"
        # Offer to restore from backup
        offer_rollback
    fi
}

trap cleanup_on_error EXIT
trap 'exit 130' INT TERM

# Explicit error checking everywhere
install_package() {
    local package="$1"
    
    if ! stow -v -R -d "$DOTFILES_DIR" -t "$HOME" "$package" 2>&1; then
        log_error "Failed to install package: $package"
        log_error "Run './dot validate' to check installation"
        return 1
    fi
    
    return 0
}
```

### Phase 2: Better Context

```bash
log_error_with_context() {
    local operation="$1"
    local error="$2"
    local suggestion="$3"
    
    log_error "$operation failed: $error"
    if [[ -n "$suggestion" ]]; then
        echo "  Suggestion: $suggestion"
    fi
}

# Usage:
log_error_with_context \
    "Git config merge" \
    "Invalid git config format in .gitconfig.personal" \
    "Check syntax with: git config --file .gitconfig.personal --list"
```

### Phase 3: Rollback Support

```bash
# Track installed packages
INSTALLED_PACKAGES=()

install_with_rollback() {
    for package in "${PACKAGES[@]}"; do
        if install_package "$package"; then
            INSTALLED_PACKAGES+=("$package")
        else
            log_error "Installation failed at package: $package"
            rollback_installation
            return 1
        fi
    done
}

rollback_installation() {
    log_warning "Rolling back installation..."
    for package in "${INSTALLED_PACKAGES[@]}"; do
        log_info "Removing $package"
        stow -D "$package" 2>/dev/null || true
    done
    restore_from_latest_backup
}
```

---

## Quick Wins

### 1. Fix Hanging Process Substitution

Replace:

```bash
while read -r line; do
    # ...
done < <(git config --list)
```

With:

```bash
local git_output
git_output=$(git config --list 2>&1) || {
    log_error "Failed to read git config"
    return 1
}

while read -r line; do
    # ...
done <<< "$git_output"
```

### 2. Add Timeouts

```bash
timeout 30 curl -s "$url" || {
    log_error "Download timed out or failed"
    return 1
}
```

### 3. Better Error Messages

Before:

```bash
log_error "Failed"
```

After:

```bash
log_error "Failed to copy $template to $target"
log_error "Check permissions: ls -la $(dirname "$target")"
```

---

## Testing Error Handling

### Simulate Failures

```bash
# Test missing dependency
mv /usr/bin/stow /usr/bin/stow.bak
./dot install  # Should fail gracefully

# Test permission error
chmod 000 ~/.gitconfig
./dot install  # Should handle and report

# Test network failure
# Disconnect network
./dot update-all  # Should timeout gracefully

# Test interrupted installation
./dot install & 
sleep 2; kill %1  # Should cleanup
```

---

## Recommended Implementation

1. Remove global `set -e`
2. Add cleanup trap
3. Add explicit error checking with context
4. Fix process substitution to avoid hangs
5. Add timeouts for network operations
6. Implement rollback on failure
7. Add dry-run mode
8. Standardize error reporting
