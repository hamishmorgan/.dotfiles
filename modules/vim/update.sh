#!/usr/bin/env bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DIR}/../..

cd ${DOTFILES_BASE_DIR}/vim/.spf13-vim-3/
git pull
vim +BundleInstall! +BundleClean +q
