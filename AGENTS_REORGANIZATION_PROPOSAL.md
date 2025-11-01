# AGENTS.md Reorganization Proposal

## Executive Summary

AGENTS.md is 1,759 lines with ~27% (473 lines) being component-specific content that creates cognitive load when working on unrelated parts of the project. This proposal outlines a strategic reorganization that:

1. **Reduces core AGENTS.md by ~27%** (from 1,759 → ~1,286 lines)
2. **Enables contextual loading** of component-specific documentation
3. **Improves maintainability** by co-locating docs with code
4. **Maintains discoverability** through clear structure and references

## Current State Analysis

### Size Breakdown

| Category | Lines | Percentage | Status |
|----------|-------|------------|--------|
| Universal (standards, patterns) | ~1,162 | 66% | Keep in AGENTS.md |
| Component-specific (high scoping) | ~380 | 22% | **Move to component docs** |
| Quick reference (medium scoping) | ~93 | 5% | Consider separate quick-ref |
| Mixed sections | ~124 | 7% | Split universal/component |

**Total: 1,759 lines**

### Component-Specific Sections Identified

#### High Priority (Move Immediately)

1. **Cursor IDE Configuration** (lines 1113-1220, 107 lines)
   - Only relevant when editing `packages/cursor/`
   - Already has `packages/cursor/README.md` (51 lines)
   - **Action**: Move technical details to `.cursor/rules/cursor-config.mdc` with globs

2. **Disk Cleanup Utility** (lines 1285-1314, 29 lines)
   - Only relevant when editing `bin/disk-cleanup`
   - **Action**: Move to `bin/disk-cleanup.md` or inline comments

3. **Development Directory** (lines 1316-1338, 22 lines)
   - Only relevant when editing `dev/` scripts
   - **Action**: Move to `dev/README.md`

4. **CI/CD** (lines 1450-1531, 81 lines)
   - Only relevant when editing `.github/workflows/`
   - **Action**: Move to `.github/CONTRIBUTING.md` or `.cursor/rules/ci-cd.mdc`

5. **GitHub Integration** (lines 1657-1759, 102 lines)
   - Only relevant during PR workflow
   - Already referenced in `pull-request-workflow.mdc`
   - **Action**: Move to `.cursor/rules/github-integration.mdc` with on-demand loading

6. **Testing** (lines 1616-1655, 39 lines)
   - Only relevant when editing `tests/` or scripts needing tests
   - Already referenced in `testing-workflow.mdc`
   - Already has `tests/README.md`
   - **Action**: Move detailed strategy to `tests/README.md`, keep taxonomy reference in AGENTS.md

**Total: ~380 lines (22% reduction potential)**

#### Medium Priority (Consider Moving)

7. **Quick Reference** (lines 1533-1565, 32 lines)
   - Used frequently but could be separate
   - **Action**: Create `.cursor/rules/quick-reference.mdc` (always loaded, small)

8. **Common Tasks** (lines 1566-1615, 49 lines)
   - Used frequently but could be separate
   - **Action**: Move to `.cursor/rules/common-tasks.mdc` (always loaded, small)

**Total: ~81 lines (5% additional reduction potential)**

### Universal Sections (Keep in AGENTS.md)

These sections apply to all code and should remain in AGENTS.md:

- **Code Standards** (~600 lines): Shell script style, Bash 3.2 compatibility, error handling
- **Documentation Standards** (~8 lines): Universal writing guidelines
- **Git Commit Attribution** (~82 lines): Universal commit patterns
- **File Organization** (general, ~200 lines): Universal patterns
- **Logging System** (~21 lines): Used in `dot` script (universal pattern)
- **Verbosity System** (~16 lines): Used in `dot` script (universal pattern)
- **Helper Functions** (~12 lines): Used in `dot` script (universal pattern)
- **Project Context** (~180 lines): Repository structure, dependencies
- **Code Quality** (~8 lines): Universal linting requirements

**Total: ~1,127 lines (core reference material)**

## Proposed Structure

### Option A: Component-Specific .mdc Files (Recommended)

Leverage Cursor's glob-based loading system to create component-specific documentation:

```
.cursor/rules/
├── README.md (existing)
├── pull-request-workflow.mdc (existing)
├── testing-workflow.mdc (existing)
├── validation-workflow.mdc (existing)
├── troubleshooting-workflow.mdc (existing)
├── update-instructions-workflow.mdc (existing)
├── cursor-config.mdc (NEW - globs: ["packages/cursor/**"])
├── ci-cd.mdc (NEW - globs: [".github/workflows/**"])
├── github-integration.mdc (NEW - alwaysApply: false, referenced from PR workflow)
└── quick-reference.mdc (NEW - alwaysApply: true, small 32 lines)

bin/
└── disk-cleanup.md (NEW - component-specific docs)

dev/
└── README.md (NEW - development workflow docs)

tests/
└── README.md (ENHANCE - add testing strategy from AGENTS.md)
```

**Benefits:**
- Contextual loading reduces cognitive load
- Docs co-located with code
- Maintains existing workflow pattern
- Clear separation of concerns

**Implementation:**
1. Create `.cursor/rules/cursor-config.mdc` with glob `["packages/cursor/**"]`
2. Create `.cursor/rules/ci-cd.mdc` with glob `[".github/workflows/**"]`
3. Create `.cursor/rules/github-integration.mdc` with `alwaysApply: false`
4. Create `.cursor/rules/quick-reference.mdc` with `alwaysApply: true`
5. Create `bin/disk-cleanup.md` (standalone doc)
6. Create `dev/README.md` (development workflow)
7. Enhance `tests/README.md` with testing strategy
8. Remove moved sections from AGENTS.md
9. Add cross-references in AGENTS.md to component docs

### Option B: Component README Files (Simpler)

Move component-specific sections to README files in respective directories:

```
packages/cursor/README.md (ENHANCE - add technical details from AGENTS.md)
bin/disk-cleanup.md (NEW)
dev/README.md (NEW)
.github/CONTRIBUTING.md (NEW - CI/CD and GitHub integration)
tests/README.md (ENHANCE - add testing strategy)
```

**Benefits:**
- Simpler (no new .mdc files)
- Standard README pattern
- Docs co-located with code

**Drawbacks:**
- README files don't benefit from Cursor's glob-based loading
- Must be manually referenced
- Less discoverable for AI agents

### Option C: Hybrid Approach (Recommended)

Combine both approaches:

- **Component-specific technical details** → `.cursor/rules/*.mdc` (with globs)
- **User-facing documentation** → Component README files
- **Quick reference** → `.cursor/rules/quick-reference.mdc` (always loaded)

**Example:**

`.cursor/rules/cursor-config.mdc`:
```yaml
---
description: "Cursor IDE configuration technical details"
globs: ["packages/cursor/**"]
---
# Cursor IDE Configuration

Technical implementation details for Cursor IDE configuration...

[Content from AGENTS.md lines 1113-1220]
```

`packages/cursor/README.md`:
```markdown
# Cursor IDE Configuration

[User-facing docs - already exists]

For technical implementation details, see `.cursor/rules/cursor-config.mdc`.
```

## Implementation Plan

### Phase 1: Extract Component-Specific Sections (Low Risk)

1. Create `.cursor/rules/cursor-config.mdc`
   - Move lines 1113-1220 from AGENTS.md
   - Add glob: `["packages/cursor/**"]`
   - Add reference in `packages/cursor/README.md`

2. Create `bin/disk-cleanup.md`
   - Move lines 1285-1314 from AGENTS.md
   - Link from `bin/disk-cleanup` script header

3. Create `dev/README.md`
   - Move lines 1316-1338 from AGENTS.md
   - Add workflow examples

4. Create `.cursor/rules/ci-cd.mdc`
   - Move lines 1450-1531 from AGENTS.md
   - Add glob: `[".github/workflows/**"]`

5. Create `.cursor/rules/github-integration.mdc`
   - Move lines 1657-1759 from AGENTS.md
   - Add `alwaysApply: false`
   - Reference from `pull-request-workflow.mdc`

6. Enhance `tests/README.md`
   - Move lines 1616-1655 from AGENTS.md
   - Keep taxonomy reference in AGENTS.md (link to tests/README.md)

**Result**: AGENTS.md reduced from 1,759 → ~1,379 lines (~22% reduction)

### Phase 2: Extract Quick Reference (Optional)

7. Create `.cursor/rules/quick-reference.mdc`
   - Move lines 1533-1565 from AGENTS.md
   - Add `alwaysApply: true` (small, frequently used)

8. Create `.cursor/rules/common-tasks.mdc`
   - Move lines 1566-1615 from AGENTS.md
   - Add `alwaysApply: true` (small, frequently used)

**Result**: AGENTS.md reduced from 1,379 → ~1,286 lines (~27% total reduction)

### Phase 3: Update Cross-References

9. Update AGENTS.md:
   - Add section: "Component-Specific Documentation"
   - Link to each component doc
   - Remove moved sections
   - Update Table of Contents

10. Update workflow files:
    - Add references to new component docs
    - Update "See AGENTS.md" references to point to component docs

11. Update `.cursor/rules/README.md`:
    - Document new component-specific .mdc files
    - Explain loading strategy

## Benefits Analysis

### Cognitive Load Reduction

**Before:**
- Every conversation loads 1,759 lines
- ~380 lines (22%) irrelevant to most tasks
- Must mentally filter component-specific content

**After:**
- Core AGENTS.md: ~1,286 lines (always loaded)
- Component docs: Loaded only when relevant (via globs)
- Clear separation: Universal vs. component-specific

### Maintainability Improvement

**Before:**
- Single large file (1,759 lines)
- Component changes require editing AGENTS.md
- Risk of merge conflicts

**After:**
- Core file: ~1,286 lines (stable)
- Component docs: Co-located with code
- Easier to find and update component-specific docs
- Reduced merge conflicts

### Discoverability

**Before:**
- Component docs hidden in large AGENTS.md
- Must search 1,759 lines to find relevant section

**After:**
- Component docs in component directories
- Cursor auto-loads via globs when editing matching files
- Clear cross-references in AGENTS.md

## Risk Assessment

### Low Risk

- Moving component-specific sections (Phase 1)
- Creating component README files
- No breaking changes to existing workflows

### Medium Risk

- Updating cross-references (must ensure all links work)
- Testing glob-based loading works correctly

### Mitigation

1. **Gradual rollout**: Implement Phase 1 first, test thoroughly
2. **Cross-reference validation**: Script to check all links resolve
3. **Documentation**: Clear migration guide for maintainers
4. **Reversibility**: Keep moved sections in git history

## Migration Checklist

- [ ] Create `.cursor/rules/cursor-config.mdc` with globs
- [ ] Create `bin/disk-cleanup.md`
- [ ] Create `dev/README.md`
- [ ] Create `.cursor/rules/ci-cd.mdc` with globs
- [ ] Create `.cursor/rules/github-integration.mdc` (on-demand)
- [ ] Enhance `tests/README.md` with testing strategy
- [ ] Update AGENTS.md: Remove moved sections, add cross-references
- [ ] Update `.cursor/rules/README.md` with new files
- [ ] Update workflow files with new references
- [ ] Test glob-based loading works correctly
- [ ] Validate all cross-references resolve
- [ ] Update PR template if needed

## Success Metrics

- **Size reduction**: AGENTS.md reduced by ~27% (1,759 → ~1,286 lines)
- **Contextual loading**: Component docs load only when relevant
- **Maintainability**: Component changes don't require editing AGENTS.md
- **Discoverability**: Component docs co-located with code
- **No regressions**: All existing workflows continue to function

## Recommendations

1. **Implement Option C (Hybrid Approach)**: Best balance of discoverability and contextual loading
2. **Start with Phase 1**: Low risk, immediate benefits
3. **Evaluate Phase 2**: Monitor usage before extracting quick reference
4. **Document migration**: Update `.cursor/rules/update-instructions-workflow.mdc` with new patterns
5. **Measure impact**: Track agent context size and response quality after reorganization

## Questions to Consider

1. **Quick Reference**: Should this be always loaded (small) or on-demand?
   - **Recommendation**: Always loaded (32 lines, frequently used)

2. **Helper Functions**: Keep in AGENTS.md or move to component doc?
   - **Recommendation**: Keep in AGENTS.md (universal pattern, used in `dot` script)

3. **Testing Strategy**: Move entirely or keep taxonomy in AGENTS.md?
   - **Recommendation**: Move detailed strategy to `tests/README.md`, keep taxonomy reference in AGENTS.md

4. **File Organization**: Split universal vs. component-specific subsections?
   - **Recommendation**: Keep universal patterns in AGENTS.md, move component-specific to component docs

## Next Steps

1. Review this proposal
2. Decide on approach (Option A, B, or C)
3. Approve Phase 1 implementation
4. Create implementation PR
5. Test thoroughly before merging
6. Monitor and iterate

