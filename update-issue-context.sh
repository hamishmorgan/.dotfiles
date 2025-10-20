#!/usr/bin/env bash
# Script to update issues with additional context

set -e

echo "Updating issue #11 with documentation status..."

gh issue comment 11 --body "## Status Update

**Partially addressed - Core documentation exists**

Current documentation structure:
- ✅ **README.md**: Comprehensive user-facing documentation (installation, usage, features, configuration, troubleshooting section)
- ✅ **DEVELOPMENT.md**: Complete developer documentation (setup, workflow, testing, CI, architecture, debugging)
- ✅ **AGENTS.md**: Detailed AI agent instructions (technical implementation guidance, code standards, patterns)
- ✅ **tests/README.md**: Testing framework documentation
- ✅ **Inline help**: \`./dot --help\`, \`./dot status\`, \`./dot health\`
- ✅ **Troubleshooting sections**: Present in README.md and DEVELOPMENT.md

**What's still missing (from original proposal):**
- ❌ Dedicated \`docs/\` directory with topic-specific guides
- ❌ Advanced configuration cookbook/examples
- ❌ Platform-specific configuration guide
- ❌ Integration examples (tool-specific configurations)

**Priority remains LOW** since core documentation is comprehensive. Advanced guides would be nice-to-have for power users but aren't blocking any workflows.

Consider splitting this into specific issues if particular documentation gaps are identified (e.g., \"Document SSH package setup\", \"Create multi-machine configuration guide\")."

echo "✓ Updated #11"
echo ""
echo "Updating issue #18 with security command status..."

gh issue comment 18 --body "## Status Update

**Partially addressed by PR #63 - Security audit command**

The \`./dot security\` command (added in PR #63) now provides:
- ✅ Detection of committed secrets in tracked files
- ✅ Validation of \`.secret\` file permissions (must be 600/400)
- ✅ Verification of \`.gitignore\` coverage for secret files
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
- Security validation via \`./dot security\`
- Per-machine secret management (different secrets per machine)

**Priority remains MEDIUM**. Current approach is functional and secure for most use cases. Encryption would add defense-in-depth for scenarios where:
- Secrets need to be in version control (shared team configurations)
- Backup encryption is required
- Compliance mandates encryption at rest

Consider re-evaluating when multi-machine secret sync (#45) is implemented, as that would benefit from encryption."

echo "✓ Updated #18"
echo ""
echo "Updating issue #43 with shell completion status..."

gh issue comment 43 --body "## Status Update

**Partially addressed - Basic completion exists with recent additions**

Recent enhancements:
- ✅ \`diff\` command with completion support
- ✅ \`security\` command with completion support (PR #63)
- ✅ Updated bash and zsh completions
- ✅ Fish shell completion support
- ✅ Basic command completion works

**What's still missing from original proposal:**
- ❌ Command descriptions in completions (help text while typing)
- ❌ Package name completion for enable/disable commands
- ❌ Backup ID completion for restore command (dynamic completion)
- ❌ Inline help text in completion menu
- ❌ Enhanced zsh completion with \`_describe\` and \`_arguments\`
- ❌ Context-aware argument completion

**Current state:**
- Bash: Suggests commands only
- Zsh: Better with _describe but could be enhanced
- Fish: Basic completion works

**Priority remains MEDIUM**. Current completion is functional. Enhanced descriptions and context-aware completion would improve UX but aren't blocking workflows.

The original implementation proposals in the issue body are still valid and can be referenced when this is prioritized."

echo "✓ Updated #43"
echo ""
echo "Updating issue #68 with sub-issue references..."

gh issue comment 68 --body "## Implementation Status

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

Consider this a roadmap for incremental code quality improvements rather than a single large refactoring effort."

echo "✓ Updated #68"
echo ""
echo "✅ Successfully updated 4 issues with additional context"
