.ONESHELL:
SHELL := bash
.SHELLFLAGS := -euo pipefail -O globstar -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.DEFAULT_GOAL := help

PROFILE ?= $(shell head -1 .env 2>/dev/null | tr -d '[:space:]')
PROFILE := $(or $(PROFILE),$(shell hostname))
HOST ?= $(shell hostname)
HM := home-manager
VALID_PROFILES := shopify personal odin loki
VALID_HOSTS := odin

.PHONY: help _require-devshell _require-profile _require-host
.PHONY: check check-shell check-fish check-lua check-toml check-yaml check-markdown check-nix check-nix-lint
.PHONY: fmt fmt-nix fmt-shell fmt-fish fmt-lua fmt-toml
.PHONY: switch home-build home-switch home-diff home-dry-run home-news home-packages home-generations home-gc home-option home-repl
.PHONY: host-build host-switch host-diff

_require-profile:
	@if ! echo ' $(VALID_PROFILES) ' | grep -q ' $(PROFILE) '; then \
		printf '\033[31mError:\033[0m Unknown profile \033[1m%s\033[0m (from %s)\n' \
			"$(PROFILE)" "$$(test -f .env && echo '.env' || echo 'hostname fallback')"; \
		printf '  Valid profiles: %s\n' '$(VALID_PROFILES)'; \
		printf '  Fix: echo shopify > .env\n'; \
		exit 1; \
	fi

_require-host:
	@if ! echo ' $(VALID_HOSTS) ' | grep -q ' $(HOST) '; then \
		printf '\033[31mError:\033[0m Unknown host \033[1m%s\033[0m (from %s)\n' \
			"$(HOST)" "$$(test "$(HOST)" = "$$(hostname)" && echo 'hostname fallback' || echo 'HOST=...')"; \
		printf '  Valid hosts: %s\n' '$(VALID_HOSTS)'; \
		exit 1; \
	fi

_require-devshell:
	@test -n "$$IN_NIX_SHELL" || \
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
	git ls-files '*.bash' '*.zsh' | xargs --no-run-if-empty shellcheck
	git ls-files '*.bash' '*.zsh' | xargs --no-run-if-empty shfmt --diff

check-fish: _require-devshell ## @Linting| Syntax + formatting (fish)
	@mapfile -t files < <(git ls-files '*.fish')
	@if (( $${#files[@]} )); then
		printf 'fish --no-execute %s\n' "$${files[*]}"
		for f in "$${files[@]}"; do fish --no-execute "$$f" || exit 1; done
		printf 'fish_indent --check %s\n' "$${files[*]}"
		for f in "$${files[@]}"; do fish_indent --check "$$f" || exit 1; done
	fi

check-lua: _require-devshell ## @Linting| Format-check lua (stylua)
	git ls-files '*.lua' | xargs --no-run-if-empty stylua --check

check-toml: _require-devshell ## @Linting| Format-check toml (taplo)
	git ls-files '*.toml' | xargs --no-run-if-empty taplo check

check-yaml: _require-devshell ## @Linting| Lint yaml (yamllint)
	git ls-files '*.yml' '*.yaml' | xargs --no-run-if-empty yamllint --strict

check-markdown: _require-devshell ## @Linting| Lint markdown
	markdownlint-cli2 "*.md" "home/**/*.md" ".github/**/*.md" "!home/agents/skills/**"

check-nix: _require-devshell ## @Linting| Format-check nix (nixfmt)
	git ls-files '*.nix' | xargs --no-run-if-empty nixfmt --check

check-nix-lint: _require-devshell ## @Linting| Lint nix (statix + deadnix)
	statix check .
	deadnix --fail .

# --- Formatting ---

fmt: fmt-nix fmt-shell fmt-fish fmt-lua fmt-toml ## @Formatting| Format all files

fmt-nix: _require-devshell ## @Formatting| Format nix (nixfmt)
	git ls-files '*.nix' | xargs --no-run-if-empty nixfmt

fmt-shell: _require-devshell ## @Formatting| Format bash/zsh (shfmt)
	git ls-files '*.bash' '*.zsh' | xargs --no-run-if-empty shfmt --write

fmt-fish: _require-devshell ## @Formatting| Format fish (fish_indent)
	@git ls-files '*.fish' | while IFS= read -r f; do fish_indent --write "$$f"; done

fmt-lua: _require-devshell ## @Formatting| Format lua (stylua)
	git ls-files '*.lua' | xargs --no-run-if-empty stylua

fmt-toml: _require-devshell ## @Formatting| Format toml (taplo)
	git ls-files '*.toml' | xargs --no-run-if-empty taplo fmt

# --- Home Manager ---

switch: home-switch ## @Home Manager| Alias for home-switch

home-build: _require-devshell _require-profile ## @Home Manager| Build config without activating
	nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link

home-switch: _require-devshell _require-profile ## @Home Manager| Build and activate config
	@out=$$(nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link --print-out-paths)
	export HOME_MANAGER_BACKUP_EXT="hm-bak"
	set +e
	"$$out/activate"
	rc=$$?
	set -e
	if [ $$rc -ne 0 ]; then
		printf '\n\033[33mTip:\033[0m Run \033[1mmake home-diff\033[0m to see what would change in conflicting files.\n'
		exit $$rc
	fi

home-diff: _require-devshell _require-profile ## @Home Manager| Diff files that would be clobbered on switch
	@gen=$$(nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link --print-out-paths)
	found=0
	while IFS= read -r -d '' nf; do
		rel="$${nf#$$gen/home-files/}"
		cur="$$HOME/$$rel"
		if [ -e "$$cur" ] && ! [ -L "$$cur" ] && ! diff -q "$$cur" "$$nf" >/dev/null 2>&1; then
			found=1
			printf '\n\033[1;33m~/%s\033[0m\n' "$$rel"
			diff -u --color=always --label "a/$$rel (current)" --label "b/$$rel (incoming)" "$$cur" "$$nf" || true
		fi
	done < <(find -L "$$gen/home-files" -not -type d -print0)
	if [ "$$found" -eq 0 ]; then printf '\033[32mNo conflicts — switch is safe.\033[0m\n'; fi

home-dry-run: _require-devshell _require-profile ## @Home Manager| Show what switch would change
	nix build .#homeConfigurations.$(PROFILE).activationPackage --no-link --dry-run

home-news: _require-devshell _require-profile ## @Home Manager| Show unread news
	$(HM) news --flake .#$(PROFILE)

home-packages: _require-devshell ## @Home Manager| List installed packages
	$(HM) packages

home-generations: _require-devshell ## @Home Manager| List config generations
	$(HM) generations

home-gc: _require-devshell ## @Home Manager| Remove generations >30d + collect garbage
	$(HM) expire-generations "-30 days"
	nix-collect-garbage

home-option: _require-devshell ## @Home Manager| Inspect option (OPT=programs.git)
ifndef OPT
	$(error Usage: make home-option OPT=programs.git.settings.push)
endif
	@json=$$(nix eval .#homeConfigurations.$(PROFILE).config.$(OPT) --json 2>/dev/null) \
		&& printf '%s' "$$json" | jq . \
		|| printf '\033[33mEvaluation failed — try a more specific path (e.g. programs.git.settings)\033[0m\n' >&2

home-repl: _require-devshell ## @Home Manager| Open config in nix repl
	$(HM) repl --flake .#$(PROFILE)

# --- NixOS ---

host-build: _require-devshell _require-host ## @NixOS| Build system config without activating
	nixos-rebuild build --flake .#$(HOST)

host-switch: _require-devshell _require-host ## @NixOS| Build and activate system config (requires sudo)
	sudo nixos-rebuild switch --flake .#$(HOST)

host-diff: _require-devshell _require-host ## @NixOS| Show what would change on switch
	nixos-rebuild dry-activate --flake .#$(HOST)
