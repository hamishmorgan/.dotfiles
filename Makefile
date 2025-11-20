.ONESHELL:
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

DEFAULT_GOAL := help

.PHONY: help check check-shell check-markdown check-make check-jsonc check-tmux test-smoke test-bats test ci clean clean-docker clean-podman \
	update-gitignore deps deps-shellcheck deps-npx deps-bats deps-docker deps-podman deps-python3 deps-tmux deps-gh deps-jq

HELP_COLOR ?= 1
CLEAN_DOCKER ?= 0
CLEAN_PODMAN ?= 0
ifeq ($(HELP_COLOR),1)
COLOR_SECTION := \033[1;34m
COLOR_TARGET  := \033[1;33m
COLOR_DESC    := \033[0;37m
COLOR_RESET   := \033[0m
else
COLOR_SECTION :=
COLOR_TARGET  :=
COLOR_DESC    :=
COLOR_RESET   :=
endif

define HELP_TEXT
$(COLOR_SECTION)Available targets:$(COLOR_RESET)
  $(COLOR_TARGET)check$(COLOR_RESET)             $(COLOR_DESC)Run all fast checks (lint + configs)$(COLOR_RESET)
  $(COLOR_TARGET)check-shell$(COLOR_RESET)       $(COLOR_DESC)Run shellcheck (bash/zsh/tests)$(COLOR_RESET)
  $(COLOR_TARGET)check-markdown$(COLOR_RESET)    $(COLOR_DESC)Run markdownlint via npx$(COLOR_RESET)
  $(COLOR_TARGET)check-make$(COLOR_RESET)        $(COLOR_DESC)Syntax check Makefile$(COLOR_RESET)
  $(COLOR_TARGET)check-jsonc$(COLOR_RESET)       $(COLOR_DESC)Validate JSONC configs$(COLOR_RESET)
  $(COLOR_TARGET)check-tmux$(COLOR_RESET)        $(COLOR_DESC)Validate tmux configs$(COLOR_RESET)
  $(COLOR_TARGET)test-smoke$(COLOR_RESET)        $(COLOR_DESC)Run smoke tests (via ./dev/test-smoke)$(COLOR_RESET)
  $(COLOR_TARGET)test-bats$(COLOR_RESET)         $(COLOR_DESC)Run BATS suites (via ./dev/test-bats)$(COLOR_RESET)
  $(COLOR_TARGET)test$(COLOR_RESET)              $(COLOR_DESC)Run smoke + BATS suites$(COLOR_RESET)
  $(COLOR_TARGET)ci$(COLOR_RESET)                $(COLOR_DESC)Run CI containers (PLATFORM=alpine, etc.)$(COLOR_RESET)
  $(COLOR_TARGET)clean$(COLOR_RESET)             $(COLOR_DESC)Run all cleanup subtasks$(COLOR_RESET)
  $(COLOR_TARGET)clean-docker$(COLOR_RESET)      $(COLOR_DESC)Prune Docker cache (set CLEAN_DOCKER=1)$(COLOR_RESET)
  $(COLOR_TARGET)clean-podman$(COLOR_RESET)      $(COLOR_DESC)Prune Podman cache (set CLEAN_PODMAN=1)$(COLOR_RESET)
  $(COLOR_TARGET)update-gitignore$(COLOR_RESET)  $(COLOR_DESC)Refresh global gitignore$(COLOR_RESET)
  $(COLOR_TARGET)deps$(COLOR_RESET)              $(COLOR_DESC)Check developer dependencies$(COLOR_RESET)
endef

.PHONY: help check check-shell check-markdown check-make check-jsonc check-tmux test-smoke test-bats test ci clean update-gitignore \
	deps deps-shellcheck deps-npx deps-bats deps-container deps-gh deps-jq

help:
	@printf "%b\n" "$(HELP_TEXT)"

check-shell: deps-shellcheck
	shellcheck dot packages/bash/.bashrc* packages/bash/.bash_profile packages/zsh/.zshrc* packages/zsh/.zprofile tests/**/*.sh

check-markdown: deps-npx
	npx --yes markdownlint-cli@0.42.0 "**/*.md"

check-make:
	@command -v checkmake >/dev/null 2>&1 && checkmake Makefile || \
		(make -nB -f Makefile >/dev/null && printf "✓ make -n syntax check passed (checkmake not installed)\n")

check-jsonc: deps-python3
	./dev/check-jsonc

check-tmux: deps-tmux
	./dev/check-tmux

check: check-shell check-markdown check-make check-jsonc check-tmux

test-smoke:
	./dev/test-smoke

test-bats: deps-bats
	./dev/test-bats

test: test-smoke test-bats

ci: deps-container
	@if [[ -z "$${PLATFORM:-}" ]]; then \
		./dev/ci $${CI_ARGS:-}; \
	else \
		./dev/ci "$${PLATFORM}" $${CI_ARGS:-}; \
	fi

clean: clean-docker clean-podman

clean-docker: deps-docker
	@bash -euo pipefail -c '\
if [[ "$(CLEAN_DOCKER)" != "1" ]]; then \
  printf "⚠ Set CLEAN_DOCKER=1 to prune Docker cache (skipping)\n"; \
  exit 0; \
fi; \
if command -v docker >/dev/null 2>&1; then \
  docker system prune -f >/dev/null 2>&1; \
  printf "✓ Cleaned Docker cache\n"; \
else \
  printf "⚠ Docker not installed (skipping CLEAN_DOCKER)\n"; \
fi'

clean-podman: deps-podman
	@bash -euo pipefail -c '\
if [[ "$(CLEAN_PODMAN)" != "1" ]]; then \
  printf "⚠ Set CLEAN_PODMAN=1 to prune Podman cache (skipping)\n"; \
  exit 0; \
fi; \
if command -v podman >/dev/null 2>&1; then \
  podman system prune -f >/dev/null 2>&1; \
  printf "✓ Cleaned Podman cache\n"; \
else \
  printf "⚠ Podman not installed (skipping CLEAN_PODMAN)\n"; \
fi'

update-gitignore:
	./dev/update-gitignore

deps: deps-shellcheck deps-npx deps-bats deps-docker deps-podman deps-python3 deps-tmux deps-gh deps-jq

deps-shellcheck:
	@if command -v shellcheck >/dev/null 2>&1; then \
		printf "✓ shellcheck installed\n"; \
	else \
		printf "✗ shellcheck not found. Install: brew install shellcheck / apt-get install shellcheck\n" >&2; \
		exit 1; \
	fi

deps-npx:
	@if command -v npx >/dev/null 2>&1; then \
		printf "✓ npx installed\n"; \
	else \
		printf "✗ npx not found. Install Node.js (includes npm/npx)\n" >&2; \
		printf "  macOS:  brew install node\n" >&2; \
		printf "  Ubuntu: sudo apt-get install nodejs npm\n" >&2; \
		exit 1; \
	fi

deps-bats:
	@if command -v bats >/dev/null 2>&1; then \
		printf "✓ bats installed\n"; \
	else \
		printf "✗ bats not found. Install: npm install -g bats-core\n" >&2; \
		exit 1; \
	fi

deps-docker:
	@if command -v docker >/dev/null 2>&1; then \
		printf "✓ docker installed\n"; \
	else \
		printf "⚠ docker not found (optional). Install: https://docs.docker.com/get-docker/\n"; \
	fi

deps-podman:
	@if command -v podman >/dev/null 2>&1; then \
		printf "✓ podman installed\n"; \
	else \
		printf "⚠ podman not found (optional). Install: brew install podman / apt-get install podman\n"; \
	fi

deps-python3:
	@if command -v python3 >/dev/null 2>&1; then \
		printf "✓ python3 installed\n"; \
	else \
		printf "✗ python3 not found. Install: brew install python / apt-get install python3\n" >&2; \
		exit 1; \
	fi

deps-tmux:
	@if command -v tmux >/dev/null 2>&1; then \
		printf "✓ tmux installed\n"; \
	else \
		printf "⚠ tmux not found (optional). Install: brew install tmux / apt-get install tmux\n"; \
	fi

deps-gh:
	@if command -v gh >/dev/null 2>&1; then \
		printf "✓ gh installed\n"; \
	else \
		printf "⚠ gh not found (optional). Install: brew install gh / apt-get install gh\n"; \
	fi

deps-jq:
	@if command -v jq >/dev/null 2>&1; then \
		printf "✓ jq installed\n"; \
	else \
		printf "⚠ jq not found (optional). Install: brew install jq / apt-get install jq\n"; \
	fi


