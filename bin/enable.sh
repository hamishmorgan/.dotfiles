#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

function enable_all_modules {
    for module in $(list-modules); do
        enable_module "$module"
    done
}

function enable_module {
    local module=$1

    local module_path=${DOTFILES_BASE_DIR}/${module}

    run_hook_if_exists "${module_path}/pre-enable.sh"
    for dotfile in $(list-dotfiles "$module"); do
        enable_dotfile "$module" "$dotfile"
    done
    run_hook_if_exists "${module_path}/post-enable.sh"
}

function enable_dotfile {
    local module=$1
    local dotfile=$2

    local source_path=${DOTFILES_BASE_DIR}/${module}/${dotfile}
    local target_path=$HOME/${dotfile}

    run_hook_if_exists "${source_path}.pre-enable.sh"
    symlink_enable ${source_path} ${target_path}
    run_hook_if_exists "${source_path}.post-enable.sh"
}

function usage {
    echo -e "Usage: $0 [module [dotfile]]"
}

if [ $# -eq 0 ]; then
    enable_all_modules
elif [ $# -eq 1 ]; then
    enable_module $@
elif [ $# -eq 2 ]; then
    enable_dotfile $@
else
    usage
fi