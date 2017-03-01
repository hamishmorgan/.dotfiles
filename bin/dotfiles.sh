#!/usr/bin/env bash

#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

### Global gitignore config

ZSHRC_FILENAME=.zshrc
OHMYZSH_FILENAME=.oh-my-zsh

## Operations

function update {
    pass "Nothing to do"
}

function run_hook_if_exists {
    local hook=$1
    if [ -f "${hook}" ]; then
        debug "Running hook: ${hook}"
        . "${hook}"
    fi
}

function dotfile_action {
    local action=$1
    local module=$2
    local dotfile=$3

    target_path=$HOME/${dotfile}
    source_path=${DOTFILES_BASE_DIR}/${module}/${dotfile}

    run_hook_if_exists "${source_path}.pre-${action}.sh"
    case "$action" in
        "enable")
            symlink_install ${source_path} ${target_path}
            ;;
        "disable")
            symlink_remove ${source_path} ${target_path}
            ;;
        *)
            fail "Unknown action $action"
            ;;
    esac

    run_hook_if_exists "${source_path}.post-${action}.sh"
}

function module_action {
    local action=$1
    local module=$2
    
    local module_path=${DOTFILES_BASE_DIR}/${module}

    run_hook_if_exists "${module_path}/pre-${action}.sh"

    for dotfile in $(cat ${module_path}/dotfiles); do
        dotfile_action "$action" "$module" "$dotfile"
    done

    run_hook_if_exists "${module_path}/post-${action}.sh"
}

function enable {
    debug "Everything: Enabling"
    for module in $(cat ${DOTFILES_BASE_DIR}/modules); do
        module_action "enable" "$module"
    done
    debug "Everything: Enabled"
}

function disable {
    debug "Everything: Disabling"
    for module in $(cat ${DOTFILES_BASE_DIR}/modules); do
        module_action "disable" "$module"
    done
    debug "Everything: Disabled"
}

$@

