#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DIR}/..

source ${DOTFILES_BASE_DIR}/lib/commands.sh
source ${DOTFILES_BASE_DIR}/lib/linking.sh

function disable {
    local module=$1
    local dotfile=$2

    local source_path=$HOME/${dotfile}
    local target_path=${DOTFILES_MODULES_DIR}/${module}/${dotfile}

    symlink_disable ${source_path} ${target_path}
}

perform_action disable $@