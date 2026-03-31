# Agent Instructions

## Project Context

Nix Home Manager dotfiles. Cross-platform: macOS (aarch64-darwin) and Linux (x86_64-linux).

**Activation:** `make switch` (defaults to `PROFILE=shopify`) or `home-manager switch --flake .#<profile>`

**Profiles:** `shopify` (macOS), `personal` (Linux), `odin` (Linux)

**Layout:**

- `flake.nix` — entry point, defines `homeConfigurations` and dev shell
- `home/default.nix` — imports all modules, sets sessionPath + shell aliases
- `home/*.nix` — one module per tool (bat.nix, ghostty.nix, zed.nix, etc.)
- `home/*/default.nix` — modules with companion files (git/, fish/, bash/, zsh/, etc.)
- `home/{bash,fish,zsh}/` — shell scripts loaded via `builtins.readFile`

**Conventions:**

- Modules with companion files (scripts, templates, config) use a directory with `default.nix`
- Single-file modules are plain `.nix` files
- Shell aliases are co-located with their tool module (git aliases in git/, zed alias in zed.nix)
- Platform-specific config uses `lib.mkIf`/`lib.optionalAttrs` with `isDarwin` or `pkgs.stdenv.isLinux`
- Per-machine values (email, dotfiles path) come from `extraSpecialArgs` in flake.nix

**Dev shell:** `direnv allow` (automatic) or `nix develop` provides shellcheck, shfmt,
fish, stylua, taplo, yamllint, markdownlint-cli2, nixfmt, statix, deadnix, etc.

## Machine-Specific Configuration

`.local` file overrides (git-ignored):

- `~/.gitconfig.local` — signing key, maintenance repos
- `~/.zshrc.local` / `~/.bashrc.local` — machine-specific shell config
- `~/.claude/settings.local.json` — API keys, enterprise proxy

The `__HM_SHOPIFY_INIT_DONE` guard in shopify init scripts prevents double-sourcing.

## Code Standards

- Follow `.editorconfig`: LF endings, final newline, 2-space indent for shell
- Run `make check` before committing — runs all linters
- Run `make fmt` to auto-format all files
- Run `make help` to see all available targets
- Nix: must pass nixfmt, statix, and deadnix
- Shell: must pass shellcheck and shfmt
- Fish: must pass `fish --no-execute` and `fish_indent`

## Git Commit Attribution

AI-assisted commits use a Co-Authored-By trailer:

```text
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
```
