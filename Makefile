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

# ANSI codes
R := \033[31m
G := \033[32m
Y := \033[33m
B := \033[1m
D := \033[2m
C := \033[36m
N := \033[0m

# $(call msg,name,detail) — bold name, dim detail
define msg =
	@printf '$(B)%s$(N) $(D)%s$(N)\n' '$(1)' '$(2)'
endef

# $(call run,tool args,globs) — msg + git ls-files | xargs
define run =
	@printf '$(B)%s$(N) $(D)%s$(N)\n' '$(1)' '$(2)'
	git ls-files $(foreach g,$(2),'$(g)') | xargs --no-run-if-empty $(1)
endef

.PHONY: help _require-devshell _require-profile _require-host check check-shell check-fish \
        check-lua check-toml check-yaml check-markdown check-nix check-nix-lint fmt fmt-nix \
        fmt-shell fmt-fish fmt-lua fmt-toml update switch home-build home-switch home-diff \
        home-dry-run home-news home-packages home-generations home-gc home-option home-repl \
        host-build host-switch host-diff

_require-profile:
	@if ! echo ' $(VALID_PROFILES) ' | grep -q ' $(PROFILE) '; then \
		printf '$(R)Error:$(N) Unknown profile $(B)%s$(N) (from %s)\n' \
			"$(PROFILE)" "$$(test -f .env && echo '.env' || echo 'hostname fallback')"; \
		printf '  Valid profiles: %s\n' '$(VALID_PROFILES)'; \
		printf '  Fix: echo PROFILE=shopify > .env\n'; \
		exit 1; \
	fi

_require-host:
	@if ! echo ' $(VALID_HOSTS) ' | grep -q ' $(HOST) '; then \
		printf '$(R)Error:$(N) Unknown host $(B)%s$(N) (from %s)\n' \
			"$(HOST)" "$$(test "$(HOST)" = "$$(hostname)" && echo 'hostname fallback' || echo 'HOST=...')"; \
		printf '  Valid hosts: %s\n' '$(VALID_HOSTS)'; \
		exit 1; \
	fi

_require-devshell:
	@test -n "$$IN_NIX_SHELL" || \
		{ printf '$(R)Dev shell not active.$(N) Run: $(B)direnv allow$(N) or $(B)nix develop$(N)\n' >&2; exit 1; }

help: ## Show this help
	@printf '$(B)PROFILE=$(C)%s$(N)$(B)  HOST=$(C)%s$(N)\n\n' '$(PROFILE)' '$(HOST)'
	@grep -E '^[a-zA-Z_-]+:.*## ' $(MAKEFILE_LIST) | \
		awk -F ':.*## ' '{ \
			if (match($$2, /^@([^|]+)\| (.*)/, m)) { \
				if (m[1] != cat) { cat = m[1]; printf "$(B)\033[34m%s:$(N)\n", cat } \
				printf "  $(B)$(Y)%-16s$(N) %s\n", $$1, m[2] \
			} else { \
				printf "  $(B)$(Y)%-16s$(N) %s\n", $$1, $$2 \
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

switch: home-switch ## @Home Manager| Alias for home-switch

home-build: _require-devshell _require-profile ## @Home Manager| Build config without activating
	$(call msg,nix build,$(PROFILE))
	nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link

home-switch: _require-devshell _require-profile ## @Home Manager| Build and activate config
	$(call msg,nix build + activate,$(PROFILE))
	out=$$(nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link --print-out-paths)
	export HOME_MANAGER_BACKUP_EXT="hm-bak"
	set +e
	"$$out/activate"
	rc=$$?
	set -e
	if [ $$rc -ne 0 ]; then
		printf '\n$(Y)Tip:$(N) Run $(B)make home-diff$(N) to see what would change in conflicting files.\n'
		exit $$rc
	fi

home-diff: _require-devshell _require-profile ## @Home Manager| Diff files that would be clobbered on switch
	$(call msg,home-diff,$(PROFILE))
	gen=$$(nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link --print-out-paths)
	found=0
	while IFS= read -r -d '' nf; do
		rel="$${nf#$$gen/home-files/}"
		cur="$$HOME/$$rel"
		if [ -e "$$cur" ] && ! [ -L "$$cur" ] && ! diff -q "$$cur" "$$nf" >/dev/null 2>&1; then
			found=1
			printf '\n$(B)$(Y)~/%s$(N)\n' "$$rel"
			diff -u --color=always --label "a/$$rel (current)" --label "b/$$rel (incoming)" "$$cur" "$$nf" || true
		fi
	done < <(find -L "$$gen/home-files" -not -type d -print0)
	if [ "$$found" -eq 0 ]; then printf '$(G)No conflicts — switch is safe.$(N)\n'; fi

home-dry-run: _require-devshell _require-profile ## @Home Manager| Show what switch would change
	$(call msg,nix build --dry-run,$(PROFILE))
	nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link --dry-run

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

home-option: _require-devshell _require-profile ## @Home Manager| Inspect option (OPT=programs.git)
ifndef OPT
	$(error Usage: make home-option OPT=programs.git.settings.push)
endif
	$(call msg,nix eval,$(OPT))
	json=$$(nix eval .#homeConfigurations.$(PROFILE).config.$(OPT) --json 2>/dev/null) \
		&& printf '%s' "$$json" | jq . \
		|| printf '$(Y)Evaluation failed — try a more specific path (e.g. programs.git.settings)$(N)\n' >&2

home-repl: _require-devshell ## @Home Manager| Open config in nix repl
	$(call msg,home-manager repl,$(PROFILE))
	$(HM) repl --flake .#$(PROFILE)

# --- Flake ---

update: _require-devshell ## @Flake| Update flake inputs
	$(call msg,nix flake update,)
	nix flake update

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
