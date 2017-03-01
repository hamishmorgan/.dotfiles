#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

GITCONFIG_FILENAME=.gitconfig

## Operations

function update {
    debug "Updating: .gitconfig"
    pass "Nothing to do"
}

function enable {
    debug "Enabling: .gitconfig"
    symlink_install ${GITCONFIG_FILENAME}
    debug "Enabled: .gitconfig"
}

function disable {
    debug "Disabling: .gitconfig"
    symlink_remove ${GITCONFIG_FILENAME}
    debug "Disabled: .gitconfig"
}

$@


