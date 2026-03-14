# .dotfiles

[![CI](https://github.com/hamishmorgan/.dotfiles/workflows/CI/badge.svg)](https://github.com/hamishmorgan/.dotfiles/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nix](https://img.shields.io/badge/Nix-Home%20Manager-blue.svg)](https://nix-community.github.io/home-manager/)

Dotfiles managed with [Home Manager](https://nix-community.github.io/home-manager/) (Nix).
Cross-platform: macOS (aarch64-darwin) and Linux (x86_64-linux).

## Quick Start

```bash
# Activate configuration
home-manager switch --flake ~/.dotfiles#shopify

# Or use the Makefile shortcut
make switch
```

## Structure

```text
flake.nix              # Entry point — defines homeConfigurations.shopify
nix/
├── home.nix           # Imports all modules, sets sessionPath + xdg
├── aliases.nix        # Shared shell aliases (all shells)
├── bash.nix           # Bash config + nix/bash/*.bash
├── bat.nix            # Bat (syntax highlighting cat)
├── claude.nix         # Claude Code settings + CLAUDE.md
├── direnv.nix         # Direnv + nix-direnv (cached dev shells)
├── eza.nix            # Eza (modern ls) aliases + options
├── fish.nix           # Fish config + nix/fish/*.fish
├── fzf.nix            # Fzf (fuzzy finder) config + key bindings
├── gh.nix             # GitHub CLI
├── git.nix            # Git config + delta + commit template
├── mise.nix           # Mise (polyglot runtime manager)
├── ripgrep.nix        # Ripgrep config
├── rust.nix           # Cargo config + rustfmt
├── system.nix         # editorconfig + inputrc
├── tmux.nix           # Tmux
├── wezterm.nix        # WezTerm terminal
├── zed.nix            # Zed editor (macOS only)
├── zoxide.nix         # Zoxide (smart cd)
├── zsh.nix            # Zsh config + nix/zsh/*.zsh
├── bash/              # One file per tool (bash)
├── fish/              # One file per tool (fish)
├── zsh/               # One file per tool (zsh)
├── claude/            # Claude Code CLAUDE.md
├── git/               # Git commit message template
├── system/            # inputrc (readline config)
└── wezterm/           # WezTerm lua config
```

## Development

```bash
# Enter dev shell with all tools (shellcheck, markdownlint-cli2, nixpkgs-fmt, etc.)
nix develop -c fish

# Run all lint checks
make check

# Individual checks
make check-shell       # shellcheck
make check-markdown    # markdownlint-cli2
make check-nix         # nixpkgs-fmt
make check-nix-lint    # statix
```

## License

MIT
