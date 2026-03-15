.ONESHELL:
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

PROFILE ?= shopify

.PHONY: help check check-shell check-fish check-markdown check-nix check-nix-lint build switch news

help:
	@printf '\033[1;34mAvailable targets:\033[0m\n'
	@printf '  \033[1;33mcheck\033[0m           Run all lint checks\n'
	@printf '  \033[1;33mcheck-shell\033[0m     Run shellcheck on bash/zsh scripts\n'
	@printf '  \033[1;33mcheck-fish\033[0m      Syntax-check fish scripts\n'
	@printf '  \033[1;33mcheck-markdown\033[0m  Run markdownlint-cli2\n'
	@printf '  \033[1;33mcheck-nix\033[0m       Format-check nix files\n'
	@printf '  \033[1;33mcheck-nix-lint\033[0m  Lint nix files (statix + deadnix)\n'
	@printf '  \033[1;33mbuild\033[0m           Build config without activating\n'
	@printf '  \033[1;33mswitch\033[0m          Build and activate Home Manager config\n'

check: check-shell check-fish check-markdown check-nix check-nix-lint

check-shell:
	shellcheck nix/bash/*.bash nix/zsh/*.zsh

check-fish:
	@printf 'fish --no-execute nix/fish/*.fish\n'
	@for f in nix/fish/*.fish; do fish --no-execute "$$f" || exit 1; done

check-markdown:
	markdownlint-cli2 "*.md" "nix/**/*.md" ".github/**/*.md"

check-nix:
	nixpkgs-fmt --check nix/*.nix flake.nix

check-nix-lint:
	statix check .
	deadnix --fail .

build:
	nix run home-manager -- build --flake .#$(PROFILE)

switch:
	nix run home-manager -- switch --flake .#$(PROFILE)

news:
	nix run home-manager -- news --flake .#$(PROFILE)
