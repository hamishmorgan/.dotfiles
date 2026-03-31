# .dotfiles

[![CI](https://github.com/hamishmorgan/.dotfiles/workflows/CI/badge.svg)](https://github.com/hamishmorgan/.dotfiles/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nix](https://img.shields.io/badge/Nix-Home%20Manager-blue.svg)](https://nix-community.github.io/home-manager/)

Dotfiles managed with [Home Manager](https://nix-community.github.io/home-manager/) (Nix).
Cross-platform: macOS (aarch64-darwin) and Linux (x86_64-linux).

## Quick Start

```bash
# Activate configuration (pick your profile)
make switch                    # defaults to PROFILE=shopify
make switch PROFILE=personal
make switch PROFILE=odin

# Or call home-manager directly
home-manager switch --flake ~/.dotfiles#shopify
```

## Structure

```text
flake.nix                # Entry point — homeConfigurations (shopify, personal, odin)
home/
├── default.nix          # Imports all modules, sets sessionPath + shell aliases
├── bat.nix              # Bat (syntax-highlighting cat) + pager variables
├── claude/              # Claude Code settings + CLAUDE.md
├── delta.nix            # Delta (git diff pager)
├── direnv.nix           # Direnv + nix-direnv (cached dev shells)
├── eza.nix              # Eza (modern ls) aliases + options
├── fd.nix               # Fd (modern find)
├── fzf.nix              # Fzf (fuzzy finder) config + key bindings
├── gh.nix               # GitHub CLI
├── ghostty.nix          # Ghostty terminal (platform-aware)
├── git/                 # Git config + commit template
├── jq.nix               # Jq (JSON processor)
├── mise.nix             # Mise (polyglot runtime manager)
├── niri/                # Niri window manager config (Linux only)
├── ripgrep.nix          # Ripgrep config
├── rust.nix             # Cargo config + rustfmt
├── ssh.nix              # SSH client config
├── system/              # EditorConfig + inputrc (readline)
├── tmux.nix             # Tmux
├── wezterm/             # WezTerm terminal + lua config
├── zed.nix              # Zed editor
├── zoxide.nix           # Zoxide (smart cd)
├── bash/                # Bash config + per-tool scripts
├── fish/                # Fish config + per-tool scripts + prompt
└── zsh/                 # Zsh config + per-tool scripts
```

Modules that have companion files (scripts, templates, config) live in directories
with a `default.nix`. Everything else is a single `.nix` file.

## Profiles

| Profile | System | Use case |
|---------|--------|----------|
| `shopify` | aarch64-darwin | Work laptop (macOS) |
| `personal` | x86_64-linux | Personal desktop |
| `odin` | x86_64-linux | Home server |

## Development

The dev shell is loaded automatically via [direnv](https://direnv.net/)
(`direnv allow`), or manually with `nix develop`.

```bash
# Run all lint checks
make check

# Auto-format all files
make fmt

# See all available targets
make help
```

## License

MIT
