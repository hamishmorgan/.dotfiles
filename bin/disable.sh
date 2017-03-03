#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/lib/shared.sh

function disable {
    local module=$1
    local dotfile=$2

    local source_path=$HOME/${dotfile}
    local target_path=${DOTFILES_BASE_DIR}/${module}/${dotfile}

    symlink_disable ${source_path} ${target_path}
}

perform_action disable $@