#!/usr/bin/env bash
set -ue

DOTFILES_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source ${DOTFILES_BASE_DIR}/lib/common.sh


(git submodule update --remote dotbot)

(. $DOTFILES_BASE_DIR/modules/zsh/update.sh)

(. $DOTFILES_BASE_DIR/modules/git/update.sh)

