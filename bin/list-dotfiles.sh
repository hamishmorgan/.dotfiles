#!/usr/bin/env bash
set -eu

DOTFILES_BIN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_BIN_DIR}/..

source ${DOTFILES_BASE_DIR}/lib/commands.sh

function list_dotfiles {
    local module=$1
    local dotfile=$2
    echo $2
}

perform_action list_dotfiles $@
