# Agent Instructions

## Project Context

Nix Home Manager dotfiles. Config modules under `nix/`, shell scripts under `nix/{bash,fish,zsh}/`.

**Activation:** `home-manager switch --flake .#shopify` or `make switch`

**Layout:**

- `flake.nix` — entry point, defines `homeConfigurations.shopify`
- `nix/*.nix` — one module per tool (git.nix, fish.nix, etc.)
- `nix/{bash,fish,zsh}/` — one shell script per tool, loaded via `builtins.readFile`
- `nix/aliases.nix` — shared shell aliases (bash + zsh; fish uses abbreviations)
- `bin/` — standalone utilities

**Dev shell:** `nix develop -c fish` provides shellcheck, markdownlint-cli2, nixpkgs-fmt, etc.

## Machine-Specific Configuration

`.local` file overrides (git-ignored):

- `~/.gitconfig.local` — work email, signing key
- `~/.zshrc.local` / `~/.bashrc.local` — machine-specific shell config
- `~/.claude/settings.local.json` — API keys, enterprise proxy

Auto-appending tools (Shopify `tec agent`) periodically append init to `.local` files.
The `__HM_SHOPIFY_INIT_DONE` guard in shopify init scripts prevents double-sourcing,
but raw lines in `.local` files bypass the guard. Clean periodically.

## Code Standards

- Follow `.editorconfig`: LF endings, final newline, 2-space indent for shell
- Shell: must pass shellcheck (config: `.shellcheckrc`)
- Markdown: must pass markdownlint-cli2 (config: `.markdownlint.yml`)
- Nix: must pass nixpkgs-fmt
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
| All lint checks | `make check` |
| Shell lint | `make check-shell` |
| Markdown lint | `make check-markdown` |
| Nix format check | `make check-nix` |
| Enter dev shell | `nix develop -c fish` |
