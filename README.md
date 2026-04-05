# .dotfiles

[![CI](https://github.com/hamishmorgan/.dotfiles/workflows/CI/badge.svg)](https://github.com/hamishmorgan/.dotfiles/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nix](https://img.shields.io/badge/Nix-Home%20Manager%20%2B%20NixOS-blue.svg)](https://nixos.org/)

Dotfiles and system configuration managed with
[Home Manager](https://nix-community.github.io/home-manager/) and
[NixOS](https://nixos.org/).
Cross-platform: macOS (aarch64-darwin) and Linux (x86_64-linux).

## Quick Start

```bash
# User config (Home Manager)
make home-switch                    # PROFILE from .env or hostname
make home-switch PROFILE=odin

# System config (NixOS, requires sudo)
make host-switch                    # HOST from hostname
```

Run `make help` for all targets.

## Bootstrap (New Machine)

On a machine without Nix installed:

```bash
# 1. Install Nix (flakes enabled out of the box)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# 2. Clone and activate
git clone https://github.com/hamishmorgan/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
nix develop -c make home-switch PROFILE=<profile>
```

If replacing existing dotfiles (e.g. from dotbot), remove old symlinks
first to avoid conflicts:

```bash
rm ~/.zshrc ~/.gitconfig  # etc — whatever the old tool managed
```

If SSHing from Ghostty, install its terminfo on the remote machine
first (fixes broken backspace/delete):

```bash
infocmp xterm-ghostty | ssh <host> tic -x -
```

## Structure

```text
flake.nix              # homeConfigurations + nixosConfigurations + dev shell
home/
├── default.nix        # Imports all modules
├── *.nix              # One module per tool (bat, delta, fzf, zed, …)
├── */default.nix      # Modules with companion files (git/, niri/, …)
└── shells/            # Bash, Fish, Zsh config + per-tool scripts
hosts/
└── odin/              # NixOS system config
    ├── default.nix
    ├── configuration.nix
    └── hardware-configuration.nix
```

## Machines

| Name | System | nixpkgs | Use case |
|------|--------|---------|----------|
| `shopify` | aarch64-darwin | unstable | Work laptop (macOS), Home Manager only |
| `personal` | x86_64-linux | unstable | Personal desktop, Home Manager only |
| `odin` | x86_64-linux | unstable + stable | Desktop (AMD, RTX 3080 Ti), Home Manager + NixOS |
| `loki` | x86_64-linux | unstable | Media server (i5-4670K, Ubuntu), Home Manager only |

## Development

Dev shell loads automatically via [direnv](https://direnv.net/),
or manually with `nix develop`.

```bash
make check    # Run all linters
make fmt      # Auto-format all files
make help     # All targets
```

## License

MIT
