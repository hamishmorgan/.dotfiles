# Dotfiles Management Flake
#
# This flake provides a reproducible development environment and runtime packages
# for managing dotfiles with GNU Stow.
#
# Usage:
#   nix develop              # Enter development shell with all dependencies
#   nix profile install .#default  # Install minimal runtime (stow, git, bash)
#   nix profile install .#runtime-full  # Install full runtime with optional tools
#
# Development Shell Includes:
#   - Required: stow, git, bash
#   - Optional runtime: gh, jq, tmux, zsh, fish, bat
#   - Dev tools: shellcheck, nodejs, bats, bats-assert, bats-support, bats-file
#   - Validation: python3, lua (for ./dot health checks)
#   - Container: podman (Linux, preferred) or docker (fallback)
#
# Runtime Packages:
#   - default: Minimal set (stow, git, bash) - core functionality only
#   - runtime-full: Includes optional tools (gh, jq, tmux, zsh, fish, bat)
#
# Note: Using nixos-unstable for latest tool versions in dev environment.
#       For production builds, consider pinning to a stable release.
#
# BATS Testing:
#   Includes bats-assert, bats-support, and bats-file from GitHub (not in nixpkgs).
#   Libraries are installed to /nix/store paths and can be loaded by tests.

{
  description = "Dotfiles management with GNU Stow";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Lua version selection with fallback
        # Prefer lua5_4, fallback to lua5_3 or lua
        luaPkg =
          if pkgs ? lua5_4 then pkgs.lua5_4
          else if pkgs ? lua5_3 then pkgs.lua5_3
          else pkgs.lua;

        # Platform-specific container runtime selection
        # Linux: prefer podman, fallback to docker if podman unavailable
        # macOS: use docker if available
        containerRuntime =
          if pkgs.stdenv.isLinux then
            (if pkgs ? podman then pkgs.podman else if pkgs ? docker then pkgs.docker else null)
          else
            (if pkgs ? docker then pkgs.docker else null);

        # BATS helper libraries (not in nixpkgs, fetch from GitHub)
        # These are bash libraries that don't need building, just copying
        bats-support = pkgs.stdenv.mkDerivation {
          pname = "bats-support";
          version = "0.3.0";
          src = pkgs.fetchFromGitHub {
            owner = "bats-core";
            repo = "bats-support";
            rev = "v0.3.0";
            sha256 = "sha256-4N7XJS5XOKxMCXNC7ef9halhRpg79kUqDuRnKcrxoeo=";
          };
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/lib/bats-support
            cp -r src/* $out/lib/bats-support/
            cp load.bash $out/lib/bats-support/
          '';
        };

        bats-assert = pkgs.stdenv.mkDerivation {
          pname = "bats-assert";
          version = "2.2.4";
          src = pkgs.fetchFromGitHub {
            owner = "bats-core";
            repo = "bats-assert";
            rev = "v2.2.4";
            sha256 = "sha256-TmLCSYT9JyC09XxyfTa7Ls2aEFuwDkCiddwZxkg/8vc=";
          };
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/lib/bats-assert
            cp -r src/* $out/lib/bats-assert/
            cp load.bash $out/lib/bats-assert/
          '';
        };

        bats-file = pkgs.stdenv.mkDerivation {
          pname = "bats-file";
          version = "0.4.0";
          src = pkgs.fetchFromGitHub {
            owner = "bats-core";
            repo = "bats-file";
            rev = "v0.4.0";
            sha256 = "sha256-NJzpu1fGAw8zxRKFU2awiFM2Z3Va5WONAD2Nusgrf4o=";
          };
          dontBuild = true;
          installPhase = ''
            mkdir -p $out/lib/bats-file
            cp -r src/* $out/lib/bats-file/
            cp load.bash $out/lib/bats-file/
          '';
        };
      in
      {
        # Development shell with all dependencies
        devShells.default = pkgs.mkShell {
          buildInputs = [
            # Required runtime dependencies
            pkgs.stow
            pkgs.git
            pkgs.bash

            # Optional runtime dependencies
            pkgs.gh
            pkgs.jq
            pkgs.tmux
            pkgs.zsh
            pkgs.fish
            pkgs.bat

            # Development tools
            pkgs.shellcheck
            pkgs.nodejs    # For npx/markdownlint-cli
            pkgs.bats      # Bash Automated Testing System
            bats-support   # BATS helper library
            bats-assert    # BATS assertion library
            bats-file      # BATS file utilities

            # Validation tools (for ./dot health)
            pkgs.python3   # JSON/TOML validation (rust, cursor)
            luaPkg          # WezTerm config validation
            pkgs.gnuplot   # Gnuplot config validation
          ] ++ pkgs.lib.optional (containerRuntime != null) containerRuntime;

          shellHook = ''
            echo "✓ Dotfiles development environment"
            echo ""
            echo "Commands:"
            echo "  ./dot install    - Install dotfiles"
            echo "  ./dot status     - Check status"
            echo "  ./dot health     - Health check"
            echo ""
            echo "Development:"
            echo "  ./dev/check      - Run all validation"
            echo "  ./dev/lint       - Lint all files"
            echo "  ./dev/test       - Run all tests"
            echo ""
            echo "Note: markdownlint via npx:"
            echo "  npx --yes markdownlint-cli@0.42.0 '**/*.md'"
            echo ""
            # Set BATS helper library paths for test loading
            export BATS_LIB_PATH="${bats-support}/lib/bats-support:${bats-assert}/lib/bats-assert:${bats-file}/lib/bats-file"
            # Also add to standard locations that test_helper/common.bash checks
            export BATS_SUPPORT_PATH="${bats-support}/lib/bats-support"
            export BATS_ASSERT_PATH="${bats-assert}/lib/bats-assert"
            export BATS_FILE_PATH="${bats-file}/lib/bats-file"
          '';
        };

        # Runtime packages
        packages = {
          # Minimal runtime: core dependencies only
          # Usage: nix profile install .#default
          default = pkgs.symlinkJoin {
            name = "dotfiles-runtime";
            paths = [
              pkgs.stow
              pkgs.git
              pkgs.bash
            ];
          };

          # Full runtime: includes optional tools
          # Usage: nix profile install .#runtime-full
          runtime-full = pkgs.symlinkJoin {
            name = "dotfiles-runtime-full";
            paths = [
              pkgs.stow
              pkgs.git
              pkgs.bash
              pkgs.gh
              pkgs.jq
              pkgs.tmux
              pkgs.zsh
              pkgs.fish
              pkgs.bat
            ];
          };
        };
      }
    );
}
