#!/usr/bin/env bash
# Script to close duplicate issues identified in the reorganization plan

set -e

echo "Closing duplicate Modern CLI Tools issues (covered by #39)..."

gh issue close 90 --comment "Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for bat and all modern CLI tools including:
- bat configuration package (Phase 2)
- Platform handling for Ubuntu's batcat naming
- Shell integration with BAT_CONFIG_PATH
- Theme and syntax highlighting configuration

See #39 for complete implementation plan."

gh issue close 91 --comment "Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for fzf including:
- FZF_DEFAULT_COMMAND with ripgrep integration
- FZF_DEFAULT_OPTS with bat preview
- Shell key bindings (Ctrl-T, Alt-C)
- Integration examples across bash, zsh, fish

See #39 Phase 1 for complete fzf setup."

gh issue close 92 --comment "Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for ripgrep including:
- Configuration package with ripgreprc
- RIPGREP_CONFIG_PATH environment variable
- Smart-case, follow, hidden file settings
- Integration with fzf and bat

See #39 Phase 2 for complete ripgrep setup."

gh issue close 93 --comment "Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for eza including:
- Shell aliases (ls, ll, la, tree) with icons
- Conditional loading when eza available
- Cross-shell compatibility (bash, zsh, fish)

See #39 Phase 1 for complete eza setup."

gh issue close 95 --comment "Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for delta including:
- git-delta integration (Phase 3)
- Conditional git config includes
- Delta configuration (side-by-side, line numbers, navigate)
- Integration with git core.pager

See #39 Phase 3 for complete delta setup."

gh issue close 96 --comment "Closing as duplicate of #39.

Issue #39 provides comprehensive implementation for zoxide including:
- Shell integration with \`eval \"\$(zoxide init bash)\"\`
- Conditional loading when zoxide available
- Cross-shell support (bash, zsh, fish)
- Alias configuration (cd='z')

See #39 Phase 1 for complete zoxide setup."

echo ""
echo "Closing duplicate Zsh issues (covered by #50)..."

gh issue close 88 --comment "Closing as duplicate of #50.

Issue #50 provides comprehensive zsh improvement plan including:
- Complete Oh My Zsh replacement strategy
- Minimal plugin configuration (syntax-highlighting, autosuggestions, history-substring-search)
- Performance comparison (85% faster startup)
- Migration path with backward compatibility

Issue #50 addresses this through the \"Alternative: Keep Both\" section which provides
a profile-based approach for users who want to keep OMZ with minimal plugins.

See #50 for complete implementation plan."

gh issue close 89 --comment "Closing as duplicate of #50.

Issue #50 provides comprehensive research and evaluation of minimal zsh alternatives including:
- Detailed comparison of Pure vs Starship prompts
- Evaluation of standalone plugins vs Oh My Zsh framework
- Performance benchmarks (50-80ms vs 400-500ms startup)
- Size comparison (800KB vs 15MB)
- Modular configuration architecture

See #50 for complete research findings and recommendations."

echo ""
echo "Closing duplicate Local CI issues (covered by #48)..."

gh issue close 94 --comment "Closing as duplicate of #48.

Issue #48 provides comprehensive parallel testing implementation including:
- Parallel test execution (Section 1: \"Parallel Test Execution\")
- Background job management with progress indicators
- Result aggregation and error reporting
- Expected 50% performance improvement (4-6 min → 2-3 min)

See #48 Section 1 for complete parallel testing implementation."

gh issue close 97 --comment "Closing as duplicate of #48.

Issue #48 provides comprehensive fail-fast implementation including:
- Fast-fail option (Section 2: \"Fast-Fail Option\")
- \`./tests/run-local-ci.sh --fail-fast\` flag
- Early termination on first failure
- Configurable via --no-fail-fast flag

See #48 Section 2 for complete fail-fast implementation."

gh issue close 98 --comment "Closing as duplicate of #48.

Issue #48 provides comprehensive selective testing implementation including:
- Selective testing (Section 3: \"Selective Testing\")
- Platform-specific execution (ubuntu, alpine, all)
- Quick iteration workflow (~2 min per platform)
- Incremental testing based on changed files (Section 5)

See #48 Sections 3 and 5 for complete selective testing implementation."

echo ""
echo "✅ Successfully closed 12 duplicate issues"
echo ""
echo "Next steps:"
echo "  1. Run: ./update-issue-context.sh"
echo "  2. Review: ISSUE_REORGANIZATION_PLAN.md"
