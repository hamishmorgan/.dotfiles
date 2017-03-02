#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

function enable {
    local module=$1
    local dotfile=$2

    local source_path=${DOTFILES_BASE_DIR}/${module}/${dotfile}
    local target_path=$HOME/${dotfile}

    symlink_enable ${source_path} ${target_path}
}

perform_action enable $@