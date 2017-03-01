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

function enable {
    debug "Everything: Enabling"
    for dir in $(cat ${DOTFILES_BASE_DIR}/dotfiles); do
        for file in $(cat ${DOTFILES_BASE_DIR}/${dir}/dotfiles); do
            local pre_install_hook="${DOTFILES_BASE_DIR}/${dir}/${file}.pre_install.sh"
            if [ -f "${pre_install_hook}" ]; then
                debug "Running pre-install hook: ${pre_install_hook}"
                . "${pre_install_hook}"
            fi

            DOTFILES_LINK_TARGET=$HOME/${file}
            DOTFILES_LINK_SOURCE=${DOTFILES_BASE_DIR}/${dir}/${file}
            symlink_install ${DOTFILES_LINK_SOURCE} ${DOTFILES_LINK_TARGET}

            local post_install_hook="${DOTFILES_BASE_DIR}/${dir}/${file}.post_install.sh"
            if [ -f "${post_install_hook}" ]; then
                debug "Running post-install hook: ${post_install_hook}"
                . "${post_install_hook}"
            fi
        done
    done
    debug "Everything: Enabled"
}

function disable {
    debug "Everything: Disabling"
    for dir in $(tac ${DOTFILES_BASE_DIR}/dotfiles); do
        for file in $(tac ${DOTFILES_BASE_DIR}/${dir}/dotfiles); do
            DOTFILES_LINK_TARGET=$HOME/${file}
            DOTFILES_LINK_SOURCE=${DOTFILES_BASE_DIR}/${dir}/${file}

            local pre_remove_hook="${DOTFILES_BASE_DIR}/${dir}/${file}.pre_remove.sh"
            if [ -f "${pre_remove_hook}" ]; then
                debug "Running pre-remove hook: ${pre_remove_hook}"
                . "${pre_remove_hook}"
            fi

            symlink_remove ${DOTFILES_LINK_SOURCE} ${DOTFILES_LINK_TARGET}

            local post_remove_hook="${DOTFILES_BASE_DIR}/${dir}/${file}.post_remove.sh"
            if [ -f "${post_remove_hook}" ]; then
                debug "Running post-remove hook: ${post_remove_hook}"
                . "${post_remove_hook}"
            fi
        done
    done
    debug "Everything: Disabled"
}

$@

