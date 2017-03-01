#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

### Global gitignore config

ZSHRC_FILENAME=.zshrc
OHMYZSH_FILENAME=.oh-my-zsh

## Operations

function update {
    debug "Updating Oh My Zsh."
    pass "Nothing to do"
}

function enable {
    debug "Enabling Oh My Zsh"
    symlink_install ${ZSHRC_FILENAME}
    symlink_install ${OHMYZSH_FILENAME}
    debug "Oh My Zsh: Enabled"
}

function disable {
    debug "Disabling Oh My Zsh"
    symlink_remove ${ZSHRC_FILENAME}
    symlink_remove ${OHMYZSH_FILENAME}
    debug "Oh My Zsh: Disabled"
}

$@


