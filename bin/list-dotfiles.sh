#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

function list_all_modules {
    for module in $(list-modules); do
        echo "$module"
        list_module "$module"
    done
}

function list_module {
    local module=$1

    list-dotfiles "$module"
}

function usage {
    echo -e "Usage: $0 [module]"
}

if [ $# -eq 0 ]; then
    list_all_modules
elif [ $# -eq 1 ]; then
    list_module $@
else
    usage
fi