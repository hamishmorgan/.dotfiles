#!/usr/bin/env bash
set -u

DOTFILES_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"


(git submodule update --remote dotbot)

(. $DOTFILES_BASE_DIR/modules/zsh/update.sh)

(. $DOTFILES_BASE_DIR/modules/git/update.sh)

