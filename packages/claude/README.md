# Claude Code Configuration Package

Manages [Claude Code](https://claude.ai/code) CLI configuration using GNU Stow.

## What's Managed

- `.claude/settings.json` - Global settings (model, permissions, preferences)
- `.claude/CLAUDE.md` - Global instructions loaded for every session

## What's NOT Managed

- `.claude/settings.local.json` - Machine-specific permissions (auto-ignored by Claude Code)
- `.claude/projects/` - Project conversation history
- `.claude/history.jsonl` - Command history
- `.claude/todos/` - Todo state
- `.claude/debug/`, `.claude/statsig/`, etc. - Runtime data

## Settings Hierarchy

Claude Code uses a hierarchical settings system (per [official docs](https://docs.claude.com/en/docs/claude-code/settings)):

| Level | Path | Purpose |
|-------|------|---------|
| User (Global) | `~/.claude/settings.json` | Shared across all projects |
| User Local | `~/.claude/settings.local.json` | Personal machine overrides |
| Project | `.claude/settings.json` | Project-specific, version controlled |
| Project Local | `.claude/settings.local.json` | Personal project overrides |

Settings cascade and merge. `settings.local.json` is automatically git-ignored by Claude Code.

## Machine-Specific Configuration

For work-specific settings (API proxies, enterprise config), use `~/.claude/settings.local.json`:

```json
{
  "apiKeyHelper": "/path/to/token-helper",
  "env": {
    "ANTHROPIC_BASE_URL": "https://your-proxy.example.com"
  },
  "permissions": {
    "allow": ["Bash(work-specific-command:*)"]
  }
}
```

This file is never committed and stays machine-local.

## Usage

```bash
# Enable the package (creates symlinks)
./dot enable claude

# Check status
./dot status

# Disable if needed
./dot disable claude
```

## Available Settings

Key options for `settings.json`:

- `model` - Model selection (e.g., `"sonnet[1m]"`)
- `permissions.allow` - Pre-approved command patterns
- `permissions.deny` - Blocked command patterns
- `alwaysThinkingEnabled` - Extended thinking mode
- `env` - Environment variables for sessions
- `apiKeyHelper` - Command to retrieve API key
- `includeCoAuthoredBy` - Git commit attribution

See [Claude Code Settings Documentation](https://docs.claude.com/en/docs/claude-code/settings) for full reference.
