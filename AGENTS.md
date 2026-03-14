# Agent Instructions

## Project Context

Nix Home Manager dotfiles. Config modules under `nix/`, shell scripts under `nix/{bash,fish,zsh}/`.

**Activation:** `home-manager switch --flake .#shopify` or `make switch`

**Layout:**

- `flake.nix` — entry point, defines `homeConfigurations` (shopify + personal)
- `nix/home.nix` — imports all modules, sets sessionPath + xdg
- `nix/*.nix` — one module per tool (git.nix, fish.nix, eza.nix, etc.)
- `nix/{bash,fish,zsh}/` — shell scripts for tools without HM modules, loaded via `builtins.readFile`
- `nix/aliases.nix` — shared shell aliases via `home.shellAliases` (all shells)

**Dev shell:** `nix develop -c fish` provides shellcheck, markdownlint-cli2, nixpkgs-fmt, statix, deadnix, etc.

## Machine-Specific Configuration

`.local` file overrides (git-ignored):

- `~/.gitconfig.local` — work email, signing key, delta opt-in
- `~/.zshrc.local` / `~/.bashrc.local` — machine-specific shell config
- `~/.claude/settings.local.json` — API keys, enterprise proxy

Auto-appending tools (Shopify `tec agent`) periodically append init to `.local` files.
The `__HM_SHOPIFY_INIT_DONE` guard in shopify init scripts prevents double-sourcing,
but raw lines in `.local` files bypass the guard. Clean periodically.

## Code Standards

- Follow `.editorconfig`: LF endings, final newline, 2-space indent for shell
- Shell: must pass shellcheck
- Markdown: must pass markdownlint-cli2 (config: `.markdownlint.yml`)
- Nix: must pass nixpkgs-fmt, statix, and deadnix
- Run `make check` before committing

## Git Commit Attribution

AI agent commits must use `--author` and `--no-gpg-sign`:

```bash
git commit --author="Claude <claude@noreply.local>" --no-gpg-sign -m "message"
```

## Quick Reference

| Task | Command |
|---|---|
| Activate config | `make switch` |
| Activate (Linux) | `make switch PROFILE=personal` |
| Build without activating | `make build` |
| All lint checks | `make check` |
| Shell lint | `make check-shell` |
| Markdown lint | `make check-markdown` |
| Nix format check | `make check-nix` |
| Nix lint (statix + deadnix) | `make check-nix-lint` |
| Enter dev shell | `nix develop -c fish` |
