#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/lib/commands.sh

function list_dotfiles {
    local module=$1
    local dotfile=$2
    echo $2
}

perform_action list_dotfiles $@
