#!/usr/bin/env bash
set -eu

DOTFILES_VIM_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_VIM_DIR}/../..

cd ${DOTFILES_BASE_DIR}/vim/.spf13-vim-3/
git pull
vim +BundleInstall! +BundleClean +q
