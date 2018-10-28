#!/usr/bin/env bash
set -eu

DOTFILES_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_BIN_DIR}/..

source ${DOTFILES_BASE_DIR}/lib/commands.sh

function list_modules {
    module=$1
    echo ${module}
}

perform_module_only_action list_modules