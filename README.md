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
