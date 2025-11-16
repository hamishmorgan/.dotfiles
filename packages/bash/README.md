# Bash Package

Bash shell configuration with modular structure (similar to Fish shell) and tool integrations.

## Files Managed

- `.bashrc` - Main entry point (minimal loader)
- `.bash_profile` - Login shell environment
- `.config/bash/conf.d/*.bash` - Modular configuration files
- `.config/bash/functions/*.bash` - Custom functions

## Structure

The bash configuration is organized into modular files stored in `~/.config/bash/` (following XDG Base Directory Specification):

```text
~/.config/bash/
├── conf.d/              # Modular configuration files
│   ├── history.bash     # History settings
│   ├── options.bash     # Bash shell options
│   ├── completion.bash # Bash completion setup
│   ├── prompt.bash      # Git-aware prompt
│   ├── editor.bash      # Editor aliases (e, v, c)
│   ├── cd.bash          # Navigation aliases (.., ..., ....)
│   ├── git.bash         # Git aliases and configuration
│   ├── eza.bash         # eza (modern ls) integration
│   ├── bat.bash         # bat (syntax highlighting) integration
│   ├── fzf.bash         # fzf (fuzzy finder) integration
│   ├── zoxide.bash      # zoxide (smart cd) integration
│   ├── graphite.bash    # Graphite (stacked PRs) integration
│   ├── shadowenv.bash   # shadowenv (directory environments) integration
│   ├── dotfiles.bash    # Dotfiles completions
│   ├── shopify.bash     # Shopify dev tools
│   ├── rust.bash        # Rust toolchain integration
│   └── darwin.bash      # macOS-specific configuration
└── functions/           # Custom functions
    └── gi.bash          # gitignore.io function
```

## Features

- **Modular structure** - Each tool/feature in its own file (easy to maintain)
- **XDG compliant** - Uses `~/.config/bash/` (respects `XDG_CONFIG_HOME`)
- **Login shell environment** (`.bash_profile`) - Sets up initial environment
- **Interactive shell configuration** (`.bashrc`) - Loads modular configs
- **Tool integrations** - Organized by tool: git, eza, bat, fzf, zoxide, Graphite, shadowenv, Shopify, Rust
- **Custom aliases** - Enhanced commands and shortcuts
- **Platform detection** - Automatically loads OS-specific configs
- **Machine-specific configs** - Any `.bash` file created in `~/.config/bash/conf.d/` is automatically loaded (git-ignored)
- **Error handling** - Failed files don't break shell initialization (set `BASH_DEBUG=1` to see warnings)
- **Load order** - Files are loaded in the order returned by the shell glob (typically alphabetical);
  explicit ordering via numeric prefixes is not officially supported or necessary (no dependencies between files)

## Installation

```bash
./dot enable bash
```

## Configuration

### Machine-Specific Configuration

Create any `.bash` file in `~/.config/bash/conf.d/` for machine-specific customizations.
All `.bash` files in this directory are automatically loaded:

```bash
# Example: Create a custom config file
nano ~/.config/bash/conf.d/my-custom-config.bash
```

**Backward compatibility:** The old `~/.bashrc.local` location is still supported and will be sourced after all conf.d files.

### Platform-Specific Configuration

Platform-specific configs are automatically loaded:

- macOS: `~/.config/bash/conf.d/darwin.bash`

### Tool Integrations

All tool integrations are conditional (only load if the tool is installed):

- **git** - Git aliases and worktree shortcuts
- **eza** - Modern `ls` replacement
- **bat** - Syntax highlighting for `cat`
- **fzf** - Fuzzy finder with key bindings
- **zoxide** - Smart `cd` replacement
- **graphite** - Stacked PRs completion
- **shadowenv** - Directory environments
- **shopify** - Shopify dev tools (`/opt/dev/dev.sh` and Tec agent)
- **rust** - rustup and cargo completions

## Migration Notes

This package was restructured from a single `.bashrc` file into modular components:

- Old platform-specific files (`.bashrc.osx`, `.bashrc.linux`) have been migrated to `.config/bash/conf.d/darwin.bash`
- All tool integrations are now in individual files organized by tool name
- Machine-specific configs can be created as any `.bash` file in `~/.config/bash/conf.d/`
- Old `~/.bashrc.local` location is still supported for backward compatibility
