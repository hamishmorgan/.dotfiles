#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DIR}/..


source ${DOTFILES_BASE_DIR}/lib/common.sh
source ${DOTFILES_BASE_DIR}/lib/logging.sh

function run_hook_if_exists {
    local hook=$1
    if [ -f "${hook}" ]; then
        debug "Running hook: ${hook}"
        . "${hook}"
    fi
}

function list-modules {
    ls ${DOTFILES_MODULES_DIR}
}

function list-dotfiles {
    local module=$1
    cat ${DOTFILES_MODULES_DIR}/${module}/dotfiles
}

function foreach_module {
    trace "$@"
    local action=$1
    shift
    for module in $(list-modules); do
        ${action} "$module" $@
    done
}

function foreach_dotfile {
    trace "$@"
    local module=$1
    local action=$2
    shift;shift

    for dotfile in $(list-dotfiles ${module}); do
        ${action} "$module" "$dotfile" $@
    done
}

function with_module_hooks {
    trace "$@"

    local module=$1
    local action=$2
    shift;shift

    local module_path=${DOTFILES_MODULES_DIR}/${module}

    run_hook_if_exists "${module_path}/pre-${action}.sh"
    ${action} "${module}" $@
    run_hook_if_exists "${module_path}/post-${action}.sh"
}

function with_dotfile_hooks {
    trace "$@"

    local module=$1
    local dotfile=$2
    local action=$3
    shift;shift;shift

    local source_path=${DOTFILES_MODULES_DIR}/${module}/${dotfile}
    local target_path=${HOME}/${dotfile}

    run_hook_if_exists "${source_path}.pre-${action}.sh"
    ${action} "${module}" "${dotfile}" $@
    run_hook_if_exists "${source_path}.post-${action}.sh"
}


function perform_action {
    trace "$@"
    local action=$1

    if [ $# -eq 1 ]; then
        foreach_module with_module_hooks \
            foreach_dotfile with_dotfile_hooks \
                ${action}
        return
    fi

    local module=$2

    if [ $# -eq 2 ]; then
        foreach_dotfile "$module" with_dotfile_hooks ${action}
        return
    fi

    local dotfile=$3

    with_dotfile_hooks "$module" "$dotfile" ${action}
}

function perform_module_only_action {
    trace "$@"
    local action=$1

    if [ $# -eq 1 ]; then
        foreach_module with_module_hooks ${action}
        return
    fi

    local module=$2

    with_module_hooks "$module" ${action}
}