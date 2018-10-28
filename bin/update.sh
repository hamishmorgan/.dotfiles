#!/usr/bin/env bash
set -eu

DOTFILES_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_BIN_DIR}/..

. $DOTFILES_BASE_DIR/modules/zsh/update.sh

