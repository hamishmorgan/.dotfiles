#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/lib/shared.sh

function list_modules {
    module=$1
    echo ${module}
}

perform_module_only_action list_modules