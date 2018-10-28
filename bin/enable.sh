#!/usr/bin/env bash
set -eu

DOTFILES_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_BIN_DIR}/..

source ${DOTFILES_BASE_DIR}/lib/commands.sh
source ${DOTFILES_BASE_DIR}/lib/linking.sh

function enable {
    local module=$1
    local dotfile=$2

    local source_path=$HOME/${dotfile}
    local target_path=${DOTFILES_MODULES_DIR}/${module}/${dotfile}

    symlink_enable ${source_path} ${target_path}
}

perform_action enable $@