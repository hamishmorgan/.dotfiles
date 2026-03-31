.ONESHELL:
SHELL := bash
.SHELLFLAGS := -euo pipefail -O globstar -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

PROFILE ?= shopify
HM := home-manager

.PHONY: help check check-shell check-fish check-lua check-toml check-yaml check-markdown \
        check-nix check-nix-lint fmt fmt-nix fmt-shell fmt-fish fmt-lua fmt-toml \
        build switch dry-run news packages generations gc option repl

help:
	@printf '\033[1;34mLinting:\033[0m\n'
	@printf '  \033[1;33mcheck\033[0m           Run all lint checks\n'
	@printf '  \033[1;33mcheck-shell\033[0m     Shellcheck + shfmt (bash/zsh)\n'
	@printf '  \033[1;33mcheck-fish\033[0m      Syntax + formatting (fish)\n'
	@printf '  \033[1;33mcheck-lua\033[0m       Format-check lua files (stylua)\n'
	@printf '  \033[1;33mcheck-toml\033[0m      Format-check toml files (taplo)\n'
	@printf '  \033[1;33mcheck-yaml\033[0m      Lint yaml files (yamllint)\n'
	@printf '  \033[1;33mcheck-markdown\033[0m  Lint markdown files\n'
	@printf '  \033[1;33mcheck-nix\033[0m       Format-check nix files (nixfmt)\n'
	@printf '  \033[1;33mcheck-nix-lint\033[0m  Lint nix files (statix + deadnix)\n'
	@printf '  \033[1;33mfmt\033[0m             Auto-format all files\n'
	@printf '\033[1;34mHome Manager:\033[0m\n'
	@printf '  \033[1;33mbuild\033[0m           Build config without activating\n'
	@printf '  \033[1;33mswitch\033[0m          Build and activate config\n'
	@printf '  \033[1;33mdry-run\033[0m         Show what switch would change\n'
	@printf '  \033[1;33mnews\033[0m            Show unread Home Manager news\n'
	@printf '  \033[1;33mpackages\033[0m        List all installed packages\n'
	@printf '  \033[1;33mgenerations\033[0m     List all config generations\n'
	@printf '  \033[1;33mgc\033[0m              Remove generations >30 days old + collect garbage\n'
	@printf '  \033[1;33moption OPT=name\033[0m Inspect a config option (e.g. OPT=programs.git)\n'
	@printf '  \033[1;33mrepl\033[0m            Open config in nix repl\n'

# --- Linting ---

check: check-shell check-fish check-lua check-toml check-yaml check-markdown check-nix check-nix-lint

check-shell:
	shellcheck **/*.bash **/*.zsh
	shfmt --diff **/*.bash **/*.zsh

check-fish:
	@printf 'fish --no-execute home/fish/*.fish\n'
	@for f in home/fish/*.fish; do fish --no-execute "$$f" || exit 1; done
	@printf 'fish_indent --check home/fish/*.fish\n'
	@for f in home/fish/*.fish; do fish_indent --check "$$f" || exit 1; done

check-lua:
	stylua --check **/*.lua

check-toml:
	git ls-files '*.toml' | xargs --no-run-if-empty taplo check

check-yaml:
	git ls-files '*.yml' '*.yaml' | xargs --no-run-if-empty yamllint --strict

check-markdown:
	markdownlint-cli2 "*.md" "home/**/*.md" ".github/**/*.md"

check-nix:
	nixfmt --check **/*.nix

check-nix-lint:
	statix check .
	deadnix --fail .

fmt: fmt-nix fmt-shell fmt-fish fmt-lua fmt-toml

fmt-nix:
	nixfmt **/*.nix

fmt-shell:
	shfmt --write **/*.bash **/*.zsh

fmt-fish:
	@for f in home/fish/*.fish; do fish_indent --write "$$f"; done

fmt-lua:
	stylua **/*.lua

fmt-toml:
	git ls-files '*.toml' | xargs --no-run-if-empty taplo fmt

# --- Home Manager ---

build:
	nix build .#homeConfigurations.$(PROFILE).activationPackage --offline --no-link

switch:
	@$$(nix build .#homeConfigurations.$(PROFILE).activationPackage --offline --no-link --print-out-paths)/activate

dry-run:
	$(HM) switch -n --flake .#$(PROFILE)

news:
	$(HM) news --flake .#$(PROFILE)

packages:
	$(HM) packages

generations:
	$(HM) generations

gc:
	$(HM) expire-generations "-30 days"
	nix-collect-garbage

option:
ifndef OPT
	$(error Usage: make option OPT=programs.git.settings.push)
endif
	@json=$$(nix eval .#homeConfigurations.$(PROFILE).config.$(OPT) --json 2>/dev/null) \
		&& printf '%s' "$$json" | jq . \
		|| printf '\033[33mEvaluation failed — try a more specific path (e.g. programs.git.settings)\033[0m\n' >&2

repl:
	$(HM) repl --flake .#$(PROFILE)
