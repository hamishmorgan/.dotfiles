.ONESHELL:
SHELL := bash
.SHELLFLAGS := -euo pipefail -O globstar -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

-include .env
PROFILE ?= $(shell hostname)
HOST ?= $(shell hostname)
HM := home-manager
VALID_PROFILES := shopify personal odin loki
VALID_HOSTS := odin

# Flake references
hm-package = .\#homeConfigurations.$(PROFILE).activationPackage
hm-config  = .\#homeConfigurations.$(PROFILE).config

# ANSI escape codes
red    := \033[31m
green  := \033[32m
yellow := \033[33m
bold   := \033[1m
dim    := \033[2m
cyan   := \033[36m
reset  := \033[0m

# $(call msg,name,detail) — target: bold name, dim detail
define msg =
	@printf '$(dim)%s$(reset) $(bold)%s$(reset) $(dim)%s$(reset)\n' '$@' '$(1)' '$(2)'
endef

# $(call run,tool args,globs) — msg + git ls-files | xargs
define run =
	@printf '$(dim)%s$(reset) $(bold)%s$(reset) $(dim)%s$(reset)\n' '$@' '$(1)' '$(2)'
	git ls-files $(foreach g,$(2),'$(g)') | xargs --no-run-if-empty $(1)
endef

.PHONY: help _require-devshell _require-profile _require-host check check-shell check-fish \
        check-lua check-toml check-yaml check-markdown check-nix check-nix-lint fmt fmt-nix \
        fmt-shell fmt-fish fmt-lua fmt-toml update update-input search why switch home-build \
        home-switch home-diff home-dry-run home-news home-packages home-generations home-gc \
        home-rollback home-size home-option home-repl host-build host-switch host-diff \
        host-gc host-rollback host-size

_require-profile:
	@if ! echo ' $(VALID_PROFILES) ' | grep -q ' $(PROFILE) '; then \
		printf '$(red)Error:$(reset) Unknown profile $(bold)%s$(reset) (from %s)\n' \
			"$(PROFILE)" "$$(test -f .env && echo '.env' || echo 'hostname fallback')"; \
		printf '  Valid profiles: %s\n' '$(VALID_PROFILES)'; \
		printf '  Fix: echo PROFILE=shopify > .env\n'; \
		exit 1; \
	fi

_require-host:
	@if ! echo ' $(VALID_HOSTS) ' | grep -q ' $(HOST) '; then \
		printf '$(red)Error:$(reset) Unknown host $(bold)%s$(reset) (from %s)\n' \
			"$(HOST)" "$$(test "$(HOST)" = "$$(hostname)" && echo 'hostname fallback' || echo 'HOST=...')"; \
		printf '  Valid hosts: %s\n' '$(VALID_HOSTS)'; \
		exit 1; \
	fi

_require-devshell:
	@test -n "$$IN_NIX_SHELL" || \
		{ printf '$(red)Dev shell not active.$(reset) Run: $(bold)direnv allow$(reset) or $(bold)nix develop$(reset)\n' >&2; exit 1; }

help: ## Show this help
	@printf '$(bold)PROFILE=$(cyan)%s$(reset)$(bold)  HOST=$(cyan)%s$(reset)\n\n' '$(PROFILE)' '$(HOST)'
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk -F ':.*## ' '{ \
			if (match($$2, /^@([^|]+)\| (.*)/, m)) { \
				if (m[1] != cat) { cat = m[1]; printf "$(bold)\033[34m%s:$(reset)\n", cat } \
				printf "  $(bold)$(yellow)%-16s$(reset) %s\n", $$1, m[2] \
			} else { \
				printf "  $(bold)$(yellow)%-16s$(reset) %s\n", $$1, $$2 \
			} \
		}'

# --- Linting ---

check: check-shell check-fish check-lua check-toml check-yaml check-markdown check-nix check-nix-lint ## @Linting| Run all lint checks

check-shell: _require-devshell ## @Linting| Shellcheck + shfmt (bash/zsh)
	$(call run,shellcheck,*.bash *.zsh)
	$(call run,shfmt --diff,*.bash *.zsh)

check-fish: _require-devshell ## @Linting| Syntax + formatting (fish)
	$(call run,fish --no-execute,*.fish)
	$(call run,fish_indent --check,*.fish)

check-lua: _require-devshell ## @Linting| Format-check lua (stylua)
	$(call run,stylua --check,*.lua)

check-toml: _require-devshell ## @Linting| Format-check toml (taplo)
	$(call run,taplo check,*.toml)

check-yaml: _require-devshell ## @Linting| Lint yaml (yamllint)
	$(call run,yamllint --strict,*.yml *.yaml)

check-markdown: _require-devshell ## @Linting| Lint markdown
	$(call msg,markdownlint-cli2,*.md)
	out=$$(markdownlint-cli2 "*.md" "home/**/*.md" ".github/**/*.md" "!home/agents/skills/**" 2>&1) || { printf '%s\n' "$$out"; exit 1; }

check-nix: _require-devshell ## @Linting| Format-check nix (nixfmt)
	$(call run,nixfmt --check,*.nix)

check-nix-lint: _require-devshell ## @Linting| Lint nix (statix + deadnix)
	$(call msg,statix check,.)
	statix check .
	$(call msg,deadnix,.)
	deadnix --fail .

# --- Formatting ---

fmt: fmt-nix fmt-shell fmt-fish fmt-lua fmt-toml ## @Formatting| Format all files

fmt-nix: _require-devshell ## @Formatting| Format nix (nixfmt)
	$(call run,nixfmt,*.nix)

fmt-shell: _require-devshell ## @Formatting| Format bash/zsh (shfmt)
	$(call run,shfmt --write,*.bash *.zsh)

fmt-fish: _require-devshell ## @Formatting| Format fish (fish_indent)
	$(call run,fish_indent --write,*.fish)

fmt-lua: _require-devshell ## @Formatting| Format lua (stylua)
	$(call run,stylua,*.lua)

fmt-toml: _require-devshell ## @Formatting| Format toml (taplo)
	$(call run,taplo fmt,*.toml)

# --- Home Manager ---

switch: home-switch $(if $(filter $(HOST),$(VALID_HOSTS)),host-switch) ## Switch home config (+ host if NixOS)

home-build: _require-devshell _require-profile ## @Home Manager| Build config without activating
	$(call msg,nix build,$(PROFILE))
	nix build $(hm-package) --no-link

home-switch: _require-devshell _require-profile ## @Home Manager| Build and activate config
	$(call msg,nix build + activate,$(PROFILE))
	out=$$(nix build $(hm-package) --no-link --print-out-paths)
	export HOME_MANAGER_BACKUP_EXT="hm-bak"
	set +e
	"$$out/activate"
	rc=$$?
	set -e
	if [ $$rc -ne 0 ]; then
		printf '\n$(yellow)Tip:$(reset) Run $(bold)make home-diff$(reset) to see what would change in conflicting files.\n'
		exit $$rc
	fi

home-diff: _require-devshell _require-profile ## @Home Manager| Diff files that would be clobbered on switch
	$(call msg,home-diff,$(PROFILE))
	gen=$$(nix build $(hm-package) --no-link --print-out-paths)
	found=0
	while IFS= read -r -d '' nf; do
		rel="$${nf#$$gen/home-files/}"
		cur="$$HOME/$$rel"
		if [ -e "$$cur" ] && ! [ -L "$$cur" ] && ! diff -q "$$cur" "$$nf" >/dev/null 2>&1; then
			found=1
			printf '\n$(bold)$(yellow)~/%s$(reset)\n' "$$rel"
			diff -u --color=always --label "a/$$rel (current)" --label "b/$$rel (incoming)" "$$cur" "$$nf" || true
		fi
	done < <(find -L "$$gen/home-files" -not -type d -print0)
	if [ "$$found" -eq 0 ]; then printf '$(green)No conflicts — switch is safe.$(reset)\n'; fi

home-dry-run: _require-devshell _require-profile ## @Home Manager| Show what switch would change
	$(call msg,nix build --dry-run,$(PROFILE))
	nix build $(hm-package) --no-link --dry-run

home-news: _require-devshell _require-profile ## @Home Manager| Show unread news
	$(call msg,home-manager news,$(PROFILE))
	$(HM) news --flake .#$(PROFILE)

home-packages: _require-devshell ## @Home Manager| List installed packages
	$(call msg,home-manager packages,)
	$(HM) packages

home-generations: _require-devshell ## @Home Manager| List config generations
	$(call msg,home-manager generations,)
	$(HM) generations

home-gc: _require-devshell ## @Home Manager| Remove generations >30d + collect garbage
	$(call msg,expire-generations,-30 days)
	$(HM) expire-generations "-30 days"
	$(call msg,nix store gc,)
	nix store gc

home-rollback: _require-devshell ## @Home Manager| Activate the previous generation
	$(call msg,home-manager rollback,)
	$(HM) generations | head -2
	$(HM) activate-generation "$$($(HM) generations | sed -n '2s/ .*//p')"

home-size: _require-devshell _require-profile ## @Home Manager| Show closure size
	$(call msg,nix path-info,$(PROFILE))
	out=$$(nix build $(hm-package) --no-link --print-out-paths)
	nix path-info -Sh "$$out"

home-option: _require-devshell _require-profile ## @Home Manager| Inspect option (OPT=programs.git)
ifndef OPT
	$(error Usage: make home-option OPT=programs.git.settings.push)
endif
	$(call msg,nix eval,$(OPT))
	json=$$(nix eval $(hm-config).$(OPT) --json 2>/dev/null) \
		&& printf '%s' "$$json" | jq . \
		|| printf '$(yellow)Evaluation failed — try a more specific path (e.g. programs.git.settings)$(reset)\n' >&2

home-repl: _require-devshell ## @Home Manager| Open config in nix repl
	$(call msg,home-manager repl,$(PROFILE))
	$(HM) repl --flake .#$(PROFILE)

# --- Flake ---

update: _require-devshell ## @Flake| Update all flake inputs
	$(call msg,nix flake update,)
	nix flake update

update-input: _require-devshell ## @Flake| Update one input (INPUT=nixpkgs-unstable)
ifndef INPUT
	$(error Usage: make update-input INPUT=nixpkgs-unstable)
endif
	$(call msg,nix flake update,$(INPUT))
	nix flake update $(INPUT)

search: _require-devshell ## @Flake| Search nixpkgs (TERM=ripgrep)
ifndef TERM
	$(error Usage: make search TERM=ripgrep)
endif
	$(call msg,nix search,$(TERM))
	nix search nixpkgs $(TERM)

why: _require-devshell _require-profile ## @Flake| Show why a package is in the closure (PKG=hello)
ifndef PKG
	$(error Usage: make why PKG=hello)
endif
	$(call msg,nix why-depends,$(PKG))
	nix why-depends $(hm-package) nixpkgs\#$(PKG) --derivation

# --- NixOS ---

host-build: _require-devshell _require-host ## @NixOS| Build system config without activating
	$(call msg,nixos-rebuild build,$(HOST))
	nixos-rebuild build --flake .#$(HOST)

host-switch: _require-devshell _require-host ## @NixOS| Build and activate system config (requires sudo)
	$(call msg,nixos-rebuild switch,$(HOST))
	sudo nixos-rebuild switch --flake .#$(HOST)

host-diff: _require-devshell _require-host ## @NixOS| Show what would change on switch
	$(call msg,nixos-rebuild dry-activate,$(HOST))
	nixos-rebuild dry-activate --flake .#$(HOST)

host-gc: _require-devshell _require-host ## @NixOS| Remove old system generations + collect garbage
	$(call msg,nix-collect-garbage,$(HOST))
	sudo nix-collect-garbage --delete-older-than 30d
	sudo nix store gc

host-rollback: _require-devshell _require-host ## @NixOS| Roll back to the previous system generation
	$(call msg,nixos-rebuild switch --rollback,$(HOST))
	sudo nixos-rebuild switch --rollback --flake .#$(HOST)

host-size: _require-devshell _require-host ## @NixOS| Show system closure size
	$(call msg,nix path-info,$(HOST))
	nix path-info -Sh /run/current-system
