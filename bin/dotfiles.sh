#!/usr/bin/env bash

#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

### Global gitignore config

ZSHRC_FILENAME=.zshrc
OHMYZSH_FILENAME=.oh-my-zsh

## Operations

function run_hook_if_exists {
    local hook=$1
    if [ -f "${hook}" ]; then
        debug "Running hook: ${hook}"
        . "${hook}"
    fi
}

function perform_action_on_dotfile {
    local action=$1
    local module=$2
    local dotfile=$3

    local target_path=$HOME/${dotfile}
    local source_path=${DOTFILES_BASE_DIR}/${module}/${dotfile}

    run_hook_if_exists "${source_path}.pre-${action}.sh"

    symlink_${action} ${source_path} ${target_path}

    run_hook_if_exists "${source_path}.post-${action}.sh"
}

function perform_action_on_module {
    local action=$1
    local module=$2

    local module_path=${DOTFILES_BASE_DIR}/${module}

    run_hook_if_exists "${module_path}/pre-${action}.sh"

    for dotfile in $(cat ${module_path}/dotfiles); do
        perform_action_on_dotfile $@ "$dotfile"
    done

    run_hook_if_exists "${module_path}/post-${action}.sh"
}

function perform_action_on_all_modules {
    local action=$1

    debug "Modules: $action"
    for module in $(list-modules); do
        perform_action_on_module $@ "$module"
    done
    debug "Modules: $action"
}

function list-modules {
    cat ${DOTFILES_BASE_DIR}/modules
}

function enable {
    perform_action_on_all_modules "enable" $@
}

function disable {
    perform_action_on_all_modules "disable" $@
}

$@


