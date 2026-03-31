.ONESHELL:
SHELL := bash
.SHELLFLAGS := -euo pipefail -O globstar -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

PROFILE ?= shopify
HM := home-manager

.PHONY: help _require-devshell check check-shell check-fish check-lua check-toml check-yaml \
        check-markdown check-nix check-nix-lint fmt fmt-nix fmt-shell fmt-fish fmt-lua fmt-toml \
        build switch dry-run news packages generations gc option repl

_require-devshell:
	@command -v shellcheck >/dev/null 2>&1 || \
		{ printf '\033[31mDev shell not active.\033[0m Run: \033[1mdirenv allow\033[0m or \033[1mnix develop\033[0m\n' >&2; exit 1; }

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk -F ':.*## ' '{ \
			if (match($$2, /^@([^|]+)\| (.*)/, m)) { \
				if (m[1] != cat) { cat = m[1]; printf "\033[1;34m%s:\033[0m\n", cat } \
				printf "  \033[1;33m%-16s\033[0m %s\n", $$1, m[2] \
			} else { \
				printf "  \033[1;33m%-16s\033[0m %s\n", $$1, $$2 \
			} \
		}'

# --- Linting ---

check: check-shell check-fish check-lua check-toml check-yaml check-markdown check-nix check-nix-lint ## @Linting| Run all lint checks

check-shell: _require-devshell ## @Linting| Shellcheck + shfmt (bash/zsh)
	shellcheck **/*.bash **/*.zsh
	shfmt --diff **/*.bash **/*.zsh

check-fish: _require-devshell ## @Linting| Syntax + formatting (fish)
	@printf 'fish --no-execute home/fish/*.fish\n'
	@for f in home/fish/*.fish; do fish --no-execute "$$f" || exit 1; done
	@printf 'fish_indent --check home/fish/*.fish\n'
	@for f in home/fish/*.fish; do fish_indent --check "$$f" || exit 1; done

check-lua: _require-devshell ## @Linting| Format-check lua (stylua)
	stylua --check **/*.lua

check-toml: _require-devshell ## @Linting| Format-check toml (taplo)
	git ls-files '*.toml' | xargs --no-run-if-empty taplo check

check-yaml: _require-devshell ## @Linting| Lint yaml (yamllint)
	git ls-files '*.yml' '*.yaml' | xargs --no-run-if-empty yamllint --strict

check-markdown: _require-devshell ## @Linting| Lint markdown
	markdownlint-cli2 "*.md" "home/**/*.md" ".github/**/*.md"

check-nix: _require-devshell ## @Linting| Format-check nix (nixfmt)
	nixfmt --check **/*.nix

check-nix-lint: _require-devshell ## @Linting| Lint nix (statix + deadnix)
	statix check .
	deadnix --fail .

# --- Formatting ---

fmt: fmt-nix fmt-shell fmt-fish fmt-lua fmt-toml ## @Formatting| Format all files

fmt-nix: _require-devshell ## @Formatting| Format nix (nixfmt)
	nixfmt **/*.nix

fmt-shell: _require-devshell ## @Formatting| Format bash/zsh (shfmt)
	shfmt --write **/*.bash **/*.zsh

fmt-fish: _require-devshell ## @Formatting| Format fish (fish_indent)
	@for f in home/fish/*.fish; do fish_indent --write "$$f"; done

fmt-lua: _require-devshell ## @Formatting| Format lua (stylua)
	stylua **/*.lua

fmt-toml: _require-devshell ## @Formatting| Format toml (taplo)
	git ls-files '*.toml' | xargs --no-run-if-empty taplo fmt

# --- Home Manager ---

build: _require-devshell ## @Home Manager| Build config without activating
	nix build .#homeConfigurations.$(PROFILE).activationPackage --offline --no-link

switch: _require-devshell ## @Home Manager| Build and activate config
	@$$(nix build .#homeConfigurations.$(PROFILE).activationPackage --offline --no-link --print-out-paths)/activate

dry-run: _require-devshell ## @Home Manager| Show what switch would change
	$(HM) switch -n --flake .#$(PROFILE)

news: _require-devshell ## @Home Manager| Show unread news
	$(HM) news --flake .#$(PROFILE)

packages: _require-devshell ## @Home Manager| List installed packages
	$(HM) packages

generations: _require-devshell ## @Home Manager| List config generations
	$(HM) generations

gc: _require-devshell ## @Home Manager| Remove generations >30d + collect garbage
	$(HM) expire-generations "-30 days"
	nix-collect-garbage

option: _require-devshell ## @Home Manager| Inspect option (OPT=programs.git)
ifndef OPT
	$(error Usage: make option OPT=programs.git.settings.push)
endif
	@json=$$(nix eval .#homeConfigurations.$(PROFILE).config.$(OPT) --json 2>/dev/null) \
		&& printf '%s' "$$json" | jq . \
		|| printf '\033[33mEvaluation failed — try a more specific path (e.g. programs.git.settings)\033[0m\n' >&2

repl: _require-devshell ## @Home Manager| Open config in nix repl
	$(HM) repl --flake .#$(PROFILE)
