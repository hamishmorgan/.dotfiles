#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

function disable_all_modules {
    for module in $(list-modules); do
        disable_module "$module"
    done
}

function disable_module {
    local module=$1

    local module_path=${DOTFILES_BASE_DIR}/${module}

    run_hook_if_exists "${module_path}/pre-disable.sh"
    for dotfile in $(list-dotfiles "$module"); do
        disable_dotfile "$module" "$dotfile"
    done
    run_hook_if_exists "${module_path}/post-disable.sh"
}

function disable_dotfile {
    local module=$1
    local dotfile=$2

    local source_path=${DOTFILES_BASE_DIR}/${module}/${dotfile}
    local target_path=$HOME/${dotfile}

    run_hook_if_exists "${source_path}.pre-disable.sh"
    symlink_disable ${source_path} ${target_path}
    run_hook_if_exists "${source_path}.post-disable.sh"
}

function usage {
    echo -e "Usage: $0 [module [dotfile]]"
}

if [ $# -eq 0 ]; then
    disable_all_modules
elif [ $# -eq 1 ]; then
    disable_module $@
elif [ $# -eq 2 ]; then
    disable_dotfile $@
else
    usage
fi