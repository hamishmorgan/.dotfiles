#!/usr/bin/env bash

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
source ${DOTFILES_BASE_DIR}/lib/shared.sh

### Global gitignore config

GITIGNORE_GLOBALS_FILENAME=.gitignore-globals
GITIGNORE_GLOBALS_TYPES='vim,jetbrains,linux'

# Gitignore IO

GITIGNOREIO_ENDPOINT=https://www.gitignore.io/api

function download_gitignore {
    local types=$1
    local dest=$2

    local url=$GITIGNOREIO_ENDPOINT/$types

    debug "Downloading '$url' to '$dest'"

    curl --silent $url > $dest \
        || fail "Download failed"

    debug "Downloaded '$url' to '$dest'"
}

## Operations

GITIGNORE_GLOBALS_LINK_PATH=$HOME/${GITIGNORE_GLOBALS_FILENAME}
GITIGNORE_GLOBALS_DOTFILE_PATH=${DOTFILES_BASE_DIR}/${GITIGNORE_GLOBALS_FILENAME}

function update {
    debug "Updating gitignore globals file '$GITIGNORE_GLOBALS_DOTFILE_PATH'."

    git_ensure_file_unchanged ${GITIGNORE_GLOBALS_DOTFILE_PATH}

    download_gitignore ${GITIGNORE_GLOBALS_TYPES} ${GITIGNORE_GLOBALS_DOTFILE_PATH}

    git_add_single_file ${GITIGNORE_GLOBALS_DOTFILE_PATH}

    success "Done; gitignore globals file '$GITIGNORE_GLOBALS_DOTFILE_PATH' updated."
}

update $@
