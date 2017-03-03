#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/lib/shared.sh

cd ${DOTFILES_BASE_DIR}/vim/.spf13-vim-3/
git pull
vim +BundleInstall! +BundleClean +q
