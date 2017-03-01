#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/bin/.shared.sh

### Global gitignore config

ZSHRC_FILENAME=.zshrc
OHMYZSH_FILENAME=.oh-my-zsh

## Operations

ZSHRC_LINK_PATH=$HOME/${ZSHRC_FILENAME}
ZSHRC_DOTFILE_PATH=${DOTFILES_BASE_DIR}/${ZSHRC_FILENAME}

OHMYZSH_LINK_PATH=$HOME/${OHMYZSH_FILENAME}
OHMYZSH_DOTFILE_PATH=${DOTFILES_BASE_DIR}/${OHMYZSH_FILENAME}

function update {
    debug "Updating Oh My Zsh."
    pass "Nothing to do"
}

function enable {
    debug "Enabling Oh My Zsh"
    symlink_install ${ZSHRC_DOTFILE_PATH} ${ZSHRC_LINK_PATH}
    symlink_install ${OHMYZSH_DOTFILE_PATH} ${OHMYZSH_LINK_PATH}
    debug "Oh My Zsh: Enabled"
}

function disable {
    debug "Disabling Oh My Zsh"
    symlink_remove ${ZSHRC_DOTFILE_PATH} ${ZSHRC_LINK_PATH}
    symlink_remove ${OHMYZSH_DOTFILE_PATH} ${OHMYZSH_LINK_PATH}
    debug "Oh My Zsh: Disabled"
}

$@


