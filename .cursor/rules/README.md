# Cursor Rules Directory

This directory contains procedural workflow files for AI agents working in Cursor IDE.
These files use frontmatter to control when they're loaded into the agent's context.

## File Structure

### Workflows (Procedural Step-by-Step)

- **`pull-request-workflow.mdc`** - Complete PR lifecycle from creation to merge
  - Load strategy: On-demand (`alwaysApply: false`)
  - Rationale: Only needed during PR operations, not every conversation

- **`testing-workflow.mdc`** - Test-driven development patterns and critical principles
  - Load strategy: Context-based (`globs: ["tests/**", "*.bats", "dot", "bin/*", "dev/*"]`)
  - Rationale: Loads when editing tests or scripts that need tests

- **`validation-workflow.mdc`** - Pre-commit validation gates (linting, smoke tests, CI)
  - Load strategy: Always loaded (`alwaysApply: true`)
  - Rationale: Critical guardrails that must be enforced before every commit

- **`troubleshooting-workflow.mdc`** - Common issues and resolution procedures
  - Load strategy: On-demand (`alwaysApply: false`)
  - Rationale: Reference material accessed when encountering specific problems

### Meta-Documentation

- **`update-instructions-workflow.mdc`** - How to maintain AGENTS.md and workflow files
  - Load strategy: Context-based (`globs: ["AGENTS.md", ".cursor/rules/**/*"]`)
  - Rationale: Only loads when editing documentation files

## Frontmatter Strategy

Each `.mdc` file uses YAML frontmatter to control loading behavior:

### Always Loaded

```yaml
---
description: "Brief purpose"
alwaysApply: true
---
```

Use sparingly - increases context size for every conversation.

**Current:** Only `validation-workflow.mdc` (critical pre-commit gates)

### Context-Based (Globs)

```yaml
---
description: "Brief purpose"
globs: ["pattern/**", "*.ext"]
---
```

Loads only when editing matching files.

**Current:**

- `testing-workflow.mdc` - Test files and scripts needing tests
- `update-instructions-workflow.mdc` - Documentation files

### On-Demand

```yaml
---
description: "Brief purpose"
alwaysApply: false
---
```

Loaded only when explicitly requested by agent or when relevant to task.

**Current:**

- `pull-request-workflow.mdc` - PR operations
- `troubleshooting-workflow.mdc` - Problem resolution

## Workflows vs Reference Material

**Workflows (in this directory):**

- Procedural, step-by-step instructions
- Action-oriented with clear sequences
- Use enforcing language (must/never/always)
- Examples: PR checklist, TDD pattern, validation gates

**Reference Material (in AGENTS.md):**

- Standards, patterns, architecture
- Context and rationale
- Taxonomy and categorization
- Examples: Code standards, testing strategy, helper functions

## Relationship to AGENTS.md

AGENTS.md contains comprehensive reference material:

- Project context and structure
- Dependencies and requirements
- Code standards and patterns
- File organization conventions
- Logging and verbosity systems
- Helper functions reference
- CI/CD architecture
- Testing strategy and categories
- GitHub integration patterns

Workflows in this directory reference AGENTS.md for:

- Detailed standards (e.g., "Check for anti-patterns documented in AGENTS.md")
- Technical specifications (e.g., "See Bash 3.2 Compatibility section")
- Command references (e.g., "See Test Categories taxonomy")

## Maintenance

When adding or modifying workflows:

1. **Determine type:**
   - Procedural workflow → `.cursor/rules/*.mdc`
   - Reference material → `AGENTS.md`

2. **Choose loading strategy:**
   - Critical enforcement → `alwaysApply: true` (use sparingly)
   - File-specific → `globs: ["pattern"]`
   - On-demand → `alwaysApply: false`

3. **Write clear frontmatter:**
   - `description`: One-line purpose (appears in Cursor)
   - Explain loading strategy rationale

4. **Validate:**
   - Run `markdownlint .cursor/rules/*.mdc`
   - Test that globs trigger correctly
   - Ensure no duplicate content with AGENTS.md

5. **Update this README** if adding new files or patterns

## Design Rationale

Workflows are separated from AGENTS.md to:

- Load only relevant procedures into context
- Reduce cognitive load with smaller, focused files
- Trigger contextually via globs when editing matching files
- Enable independent updates without modifying reference material

Structure principles:

- 6 files total (5 workflows + 1 README)
- Each workflow covers a distinct procedural area
- `*-workflow.mdc` naming convention for clarity
- Strategic loading: Only validation always loaded (critical enforcement)

## Common Patterns

### Agent needs validation rules

- Always available (validation-workflow.mdc uses `alwaysApply: true`)

### Agent editing test file

- Automatically loads testing-workflow.mdc via globs

### Agent creating PR

- Requests pull-request-workflow.mdc on-demand

### Agent encounters issue

- Requests troubleshooting-workflow.mdc on-demand

### Agent editing AGENTS.md

- Automatically loads update-instructions-workflow.mdc via globs
