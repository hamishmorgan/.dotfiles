# GitHub CLI Package

GitHub CLI configuration and aliases.

## Files Managed

- `.config/gh/config.yml` - GitHub CLI configuration
- `.config/gh/hosts.yml` - GitHub hosts and authentication

## Features

- **GitHub CLI configuration** - Editor, git protocol, browser preferences
- **Custom aliases** - Shortcuts for common operations
- **Authentication** - GitHub.com credentials

## Installation

```bash
./dot enable gh
```

## Authentication

After installation, authenticate with GitHub:

```bash
gh auth login
```

Follow the prompts to:

1. Select GitHub.com
2. Choose authentication method (browser or token)
3. Complete authentication flow

## Configuration

The installed configuration includes:

- Git protocol: SSH
- Editor: vim
- Browser: default system browser

Customize in `~/.config/gh/config.yml` (symlinked from this package).

## What Makes This Different

**Pre-configured for SSH:** Uses SSH protocol by default for git operations, avoiding HTTPS password prompts.
