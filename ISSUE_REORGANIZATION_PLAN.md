# Issue Reorganization Plan

## Summary

Reviewed all 45 open issues and identified significant redundancy. This plan consolidates duplicate issues under comprehensive parent issues and updates others with additional context.

---

## 🔴 CLOSE AS REDUNDANT

### Modern CLI Tools (Issues #90-96 → Consolidated into #39)

**Parent Issue: #39 "Add modern CLI tools configuration (bat, fzf, ripgrep, eza)"**
- Comprehensive implementation plan with phases
- Covers all tools with shell integration patterns
- Includes configuration files, graceful degradation, testing strategy

**Close these as duplicates:**

**#90 - Add bat configuration package**
```
Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for bat and all modern CLI tools including:
- bat configuration package (Phase 2)
- Platform handling for Ubuntu's batcat naming
- Shell integration with BAT_CONFIG_PATH
- Theme and syntax highlighting configuration

See #39 for complete implementation plan.
```

**#91 - Add fzf configuration and shell integration**
```
Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for fzf including:
- FZF_DEFAULT_COMMAND with ripgrep integration  
- FZF_DEFAULT_OPTS with bat preview
- Shell key bindings (Ctrl-T, Alt-C)
- Integration examples across bash, zsh, fish

See #39 Phase 1 for complete fzf setup.
```

**#92 - Add ripgrep configuration package**
```
Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for ripgrep including:
- Configuration package with ripgreprc
- RIPGREP_CONFIG_PATH environment variable
- Smart-case, follow, hidden file settings
- Integration with fzf and bat

See #39 Phase 2 for complete ripgrep setup.
```

**#93 - Add eza (ls replacement) shell aliases**
```
Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for eza including:
- Shell aliases (ls, ll, la, tree) with icons
- Conditional loading when eza available
- Cross-shell compatibility (bash, zsh, fish)

See #39 Phase 1 for complete eza setup.
```

**#95 - Add git-delta configuration for enhanced diffs**
```
Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for delta including:
- git-delta integration (Phase 3)
- Conditional git config includes
- Delta configuration (side-by-side, line numbers, navigate)
- Integration with git core.pager

See #39 Phase 3 for complete delta setup.
```

**#96 - Add zoxide (cd replacement) shell integration**
```
Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for zoxide including:
- Shell integration with `eval "$(zoxide init bash)"` 
- Conditional loading when zoxide available
- Cross-shell support (bash, zsh, fish)
- Alias configuration (cd='z')

See #39 Phase 1 for complete zoxide setup.
```

---

### Zsh Improvements (Issues #88-89 → Consolidated into #50)

**Parent Issue: #50 "Replace Oh My Zsh with minimal zsh configuration"**
- Comprehensive plan to replace OMZ with minimal setup
- Covers plugin selection, migration path, performance comparison
- Includes both minimal config AND Oh My Zsh optimization alternatives

**Close these as duplicates:**

**#88 - Configure Oh My Zsh with minimal plugins**
```
Closing as duplicate of #50.

Issue #50 provides comprehensive zsh improvement plan including:
- Complete Oh My Zsh replacement strategy
- Minimal plugin configuration (syntax-highlighting, autosuggestions, history-substring-search)
- Performance comparison (85% faster startup)
- Migration path with backward compatibility

Issue #50 addresses this through the "Alternative: Keep Both" section which provides
a profile-based approach for users who want to keep OMZ with minimal plugins.

See #50 for complete implementation plan.
```

**#89 - Research and evaluate minimal zsh alternatives**
```
Closing as duplicate of #50.

Issue #50 provides comprehensive research and evaluation of minimal zsh alternatives including:
- Detailed comparison of Pure vs Starship prompts
- Evaluation of standalone plugins vs Oh My Zsh framework
- Performance benchmarks (50-80ms vs 400-500ms startup)
- Size comparison (800KB vs 15MB)
- Modular configuration architecture

See #50 for complete research findings and recommendations.
```

---

### Local CI Enhancements (Issues #94, #97-98 → Consolidated into #48)

**Parent Issue: #48 "Enhance local CI with faster feedback and parallel testing"**
- Comprehensive implementation of all CI improvements
- Covers parallel execution, fail-fast, selective testing, caching, incremental testing

**Close these as duplicates:**

**#94 - Add parallel platform testing to local CI**
```
Closing as duplicate of #48.

Issue #48 provides comprehensive parallel testing implementation including:
- Parallel test execution (Section 1: "Parallel Test Execution")
- Background job management with progress indicators
- Result aggregation and error reporting
- Expected 50% performance improvement (4-6 min → 2-3 min)

See #48 Section 1 for complete parallel testing implementation.
```

**#97 - Add fail-fast option to local CI**
```
Closing as duplicate of #48.

Issue #48 provides comprehensive fail-fast implementation including:
- Fast-fail option (Section 2: "Fast-Fail Option")
- `./tests/run-local-ci.sh --fail-fast` flag
- Early termination on first failure
- Configurable via --no-fail-fast flag

See #48 Section 2 for complete fail-fast implementation.
```

**#98 - Add selective platform testing to local CI**
```
Closing as duplicate of #48.

Issue #48 provides comprehensive selective testing implementation including:
- Selective testing (Section 3: "Selective Testing")
- Platform-specific execution (ubuntu, alpine, all)
- Quick iteration workflow (~2 min per platform)
- Incremental testing based on changed files (Section 5)

See #48 Sections 3 and 5 for complete selective testing implementation.
```

---

## ✏️ UPDATE WITH CONTEXT

### #11 - Expand documentation with advanced usage and troubleshooting

**Add comment:**
```
## Status Update

**Partially addressed - Core documentation exists**

Current documentation structure:
- ✅ **README.md**: Comprehensive user-facing documentation (installation, usage, features, configuration, troubleshooting section)
- ✅ **DEVELOPMENT.md**: Complete developer documentation (setup, workflow, testing, CI, architecture, debugging)
- ✅ **AGENTS.md**: Detailed AI agent instructions (technical implementation guidance, code standards, patterns)
- ✅ **tests/README.md**: Testing framework documentation
- ✅ **Inline help**: `./dot --help`, `./dot status`, `./dot health`
- ✅ **Troubleshooting sections**: Present in README.md and DEVELOPMENT.md

**What's still missing (from original proposal):**
- ❌ Dedicated `docs/` directory with topic-specific guides
- ❌ Advanced configuration cookbook/examples
- ❌ Platform-specific configuration guide
- ❌ Integration examples (tool-specific configurations)

**Priority remains LOW** since core documentation is comprehensive. Advanced guides would be nice-to-have for power users but aren't blocking any workflows.

Consider splitting this into specific issues if particular documentation gaps are identified (e.g., "Document SSH package setup", "Create multi-machine configuration guide").
```

---

### #18 - Add secrets management integration

**Add comment:**
```
## Status Update

**Partially addressed by PR #63 - Security audit command**

The `./dot security` command (added in PR #63) now provides:
- ✅ Detection of committed secrets in tracked files
- ✅ Validation of `.secret` file permissions (must be 600/400)
- ✅ Verification of `.gitignore` coverage for secret files  
- ✅ SSH private key permission checks
- ✅ Comprehensive security audit reporting

**What's still missing from original proposal:**
- ❌ Encryption at rest (git-crypt, sops, age)
- ❌ Encrypted storage for secret files
- ❌ Multi-machine secret synchronization
- ❌ Secrets rotation management

**Current approach (template + gitignore + audit)** provides:
- Separation of public templates from private secrets
- Git-ignored secret files (not in version control)
- Security validation via `./dot security`
- Per-machine secret management (different secrets per machine)

**Priority remains MEDIUM**. Current approach is functional and secure for most use cases. Encryption would add defense-in-depth for scenarios where:
- Secrets need to be in version control (shared team configurations)
- Backup encryption is required
- Compliance mandates encryption at rest

Consider re-evaluating when multi-machine secret sync (#45) is implemented, as that would benefit from encryption.
```

---

### #43 - Add comprehensive shell completion with descriptions

**Add comment:**
```
## Status Update  

**Partially addressed - Basic completion exists with recent additions**

Recent enhancements:
- ✅ `diff` command with completion support (PR #XX)
- ✅ `security` command with completion support (PR #63)  
- ✅ Updated bash and zsh completions
- ✅ Fish shell completion support
- ✅ Basic command completion works

**What's still missing from original proposal:**
- ❌ Command descriptions in completions (help text while typing)
- ❌ Package name completion for enable/disable commands
- ❌ Backup ID completion for restore command (dynamic completion)
- ❌ Inline help text in completion menu
- ❌ Enhanced zsh completion with `_describe` and `_arguments`
- ❌ Context-aware argument completion

**Current state:**
- Bash: Suggests commands only
- Zsh: Better with _describe but could be enhanced
- Fish: Basic completion works

**Priority remains MEDIUM**. Current completion is functional. Enhanced descriptions and context-aware completion would improve UX but aren't blocking workflows.

The original implementation proposals in the issue body are still valid and can be referenced when this is prioritized.
```

---

### #68 - Comprehensive Code Quality & Maintainability Improvements

**Add comment:**
```
## Implementation Status

This is a **meta-issue** that tracks comprehensive code quality improvements. The specific tasks are broken down into individual issues:

**Sub-issues (all remain open):**
- #81 - Replace eval in rollback mechanism with function-based approach (medium priority, security)
- #82 - Extract large functions into smaller, testable helpers (medium priority, code quality)
- #83 - Consolidate package metadata into single data source (low priority, code quality)
- #84 - Implement verbosity-aware logging functions (medium priority, code quality)
- #85 - Standardize platform detection with centralized variables (low priority, code quality)
- #86 - Extract stable utilities to lib/ directory (low priority, architecture)
- #87 - Add unit tests for complex functions (medium priority, testing)

**Progress:**
- 0/7 completed
- 3 medium priority (start with these)
- 4 low priority

**Recommended order:**
1. #87 (Add unit tests) - Enables safer refactoring
2. #81 (Remove eval) - Security improvement
3. #82 (Extract functions) - Improves testability
4. #84 (Verbosity logging) - Enhances UX
5. #85, #83, #86 (Architecture cleanup)

**Note:** Each sub-issue should be implemented independently with its own PR. This meta-issue tracks overall progress but doesn't need to be closed until all sub-issues are complete.

Consider this a roadmap for incremental code quality improvements rather than a single large refactoring effort.
```

---

## ✅ WELL-SCOPED ISSUES (Keep as-is)

These issues are well-defined, not redundant, and should remain open:

**Recently created (good specific scopes):**
- #100 - Strengthen symlink validation to use canonical path checking
- #101 - Add ./dev/format command for auto-formatting shell and markdown files  
- #102 - Use branch-specific gitconfig for environment-specific signing

**Feature additions:**
- #10 - Add automatic update checking and submodule management
- #16 - Add interactive setup wizard
- #17 - Add shell performance profiling
- #20 - Add direnv support for per-directory environment variables
- #23 - Add plugin system for extensibility
- #31 - Distinguish between required and optional dependencies
- #32 - Add vim/neovim configuration package
- #33 - Add SSH configuration package
- #37 - Add changelog generation and release management
- #38 - Add pre-commit hooks for code quality
- #45 - Add machine-specific configuration support
- #46 - Add CONTRIBUTING.md with development guidelines
- #47 - Add export/import functionality for portable configuration

**Infrastructure improvements:**
- #77 - Add CodeQL advanced configuration
- #78 - Add Dependabot configuration for automated dependency updates
- #79 - Implement automatic backup retention policy (high priority)
- #80 - Fix broken symlinks in backups by dereferencing

**Refactoring tasks (sub-issues of #68):**
- #81-87 - Various code quality improvements

---

## 📝 NEW ISSUES TO CREATE

### Missing Issue: Container Runtime Abstraction

**Title:** Abstract container runtime to support both Docker and Podman

**Body:**
```markdown
## Problem

Local CI (`./tests/run-local-ci.sh`) hardcodes `docker` commands. Users running Podman (RedHat/Fedora default, rootless containers) must manually edit scripts or create docker→podman aliases.

## Current State

```bash
# Hardcoded in run-local-ci.sh
docker build -t dotfiles-test-ubuntu -f tests/docker/Dockerfile.ubuntu .
docker run --rm dotfiles-test-ubuntu
```

Fails on systems with Podman but not Docker.

## Proposed Solution

Detect available container runtime and use it:

```bash
# Auto-detect container runtime
detect_container_runtime() {
    if command -v docker &>/dev/null; then
        echo "docker"
    elif command -v podman &>/dev/null; then
        echo "podman"
    else
        log_error "No container runtime found (docker or podman required)"
        return 1
    fi
}

CONTAINER_RUNTIME=$(detect_container_runtime)

# Use detected runtime
$CONTAINER_RUNTIME build -t dotfiles-test-ubuntu ...
$CONTAINER_RUNTIME run --rm dotfiles-test-ubuntu
```

## Benefits

- Works on Docker and Podman without modification
- Better Linux distribution support (Fedora, RHEL use Podman)
- Rootless container support (Podman default)
- Explicit error if neither available

## Priority

**Low** - Workaround exists (docker alias), but improves portability.

## Labels

- enhancement
- low-priority
- ci
- developer-experience
- portability
```

---

### Missing Issue: Windows/WSL Support

**Title:** Add Windows/WSL support and documentation

**Body:**
```markdown
## Problem

Dotfiles repository targets macOS and Linux but doesn't document or test Windows/WSL compatibility. Many developers use WSL for development.

## Current State

- No mention of Windows/WSL in README.md or DEVELOPMENT.md
- No CI testing on Windows
- Unknown if scripts work in WSL environment
- Platform detection may not handle WSL correctly

## Proposed Solution

### Phase 1: Documentation
- Add WSL installation instructions to README.md
- Document WSL-specific considerations
- Note any known limitations

### Phase 2: Platform Detection
- Update platform detection to identify WSL
- Handle WSL-specific paths (/mnt/c vs /c)
- Detect WSL 1 vs WSL 2

### Phase 3: Testing
- Add WSL test to local CI (if feasible)
- GitHub Actions: Test on Windows with WSL

### Implementation

```bash
# Platform detection enhancement
detect_platform() {
    case "$(uname -s)" in
        Linux)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                echo "wsl"
            else
                echo "linux"
            fi
            ;;
        Darwin) echo "macos" ;;
        *) echo "unknown" ;;
    esac
}

# WSL-specific handling
if [[ "$PLATFORM" == "wsl" ]]; then
    # WSL-specific configurations
    # May need different SSH agent handling
    # May need different PATH modifications
fi
```

## Benefits

- Broader platform support
- Better documentation for Windows developers
- Confidence in WSL compatibility

## Considerations

- WSL 1 vs WSL 2 differences
- Windows filesystem limitations
- SSH agent forwarding from Windows
- Git credential management

## Priority

**Low** - WSL users can likely use it already, but formal support would be valuable.

## Labels

- enhancement
- low-priority
- documentation
- platform-support
- wsl
```

---

## 📊 Summary Statistics

**Before cleanup:**
- Total open issues: 45

**After cleanup:**
- Issues to close: 9 (90-96, 88-89, 94, 97-98)
- Issues to update: 4 (#11, #18, #43, #68)
- Issues to keep as-is: 30
- New issues to create: 2

**Final state:**
- Total open issues: 38 (45 - 9 closed + 2 new)
- Better organized with clear parent-child relationships
- Reduced redundancy
- Clearer scope per issue

---

## 🎯 Recommended Action Order

1. **Close redundant issues** (#90-96, #88-89, #94, #97-98) - 9 issues
2. **Update context** on #11, #18, #43, #68 - 4 issues
3. **Create new issues** for container runtime and WSL support - 2 issues
4. **Review high-priority** issues: #79 (backup retention), #45 (machine-specific config), #102 (branch gitconfig)

---

This reorganization will make the issue tracker more maintainable and reduce confusion about which issues to work on.
