# Agent Instructions

## Project Context

Nix Home Manager dotfiles and NixOS system config. Cross-platform: macOS (aarch64-darwin)
and Linux (x86_64-linux).

**Activation:** `make home-switch` (`PROFILE` from `.env` or hostname)
or `make host-switch` (`HOST` from hostname)

**Profiles:** `shopify` (macOS), `personal` (Linux), `odin` (Linux)

**Layout:**

- `flake.nix` — `homeConfigurations`, `nixosConfigurations`, and dev shell
- `home/*.nix` / `home/*/default.nix` — one module per tool
- `hosts/<hostname>/` — NixOS system config per host
- Two nixpkgs pins: `nixpkgs-unstable` (Home Manager) and `nixpkgs-stable` (NixOS)

**Conventions:**

- Platform-specific: `lib.mkIf` with `isDarwin` / `pkgs.stdenv.isLinux`
- Per-machine values come from `extraSpecialArgs` in flake.nix
- `hardware-configuration.nix`: use `lib.mkForce` to override, don't edit directly

## Code Standards

Run `make check` before committing. Run `make fmt` to auto-format.
Run `make help` for all targets.
