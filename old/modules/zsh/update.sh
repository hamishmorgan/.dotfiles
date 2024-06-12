#!/usr/bin/env bash
set -eu

DOTFILE_ZSH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILE_ZSH_DIR}/../..

source ${DOTFILES_BASE_DIR}/lib/git.sh


function update {
    info "Updating ZSH. "

    zsh -f $ZSH/tools/check_for_upgrade.sh

    git_add_single_file ${DOTFILE_ZSH_DIR}/.oh-my-zsh

    success "Done; ZSH updated."
}


update $@
