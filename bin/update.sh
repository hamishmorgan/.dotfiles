#!/usr/bin/env bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DIR}/..

. $DOTFILES_BASE_DIR/modules/zsh/update.sh

