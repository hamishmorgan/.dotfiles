#!/usr/bin/env bash

### Bash config

set -euo pipefail
IFS=$'\n\t'

### Dotfiles config

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))

### Global gitignore config

GITIGNORE_GLOBALS_FILENAME=.gitignore-globals
GITIGNORE_GLOBALS_TYPES='vim,netbeans,jetbrains,eclipse,linux'

### Miscellaneous constants

TRUE=0
FALSE=1

### Logging

function error {
    echo -e "\e[31m$@\e[0m"
}

function warn {
    echo -e "\e[33m$@\e[0m"
}

function info {
    echo -e "\e[32m$@\e[0m"
}

function debug {
    echo -e "\e[2m$@\e[0m"
}

## Exit status

function fail {
    error $@
    exit 1
}


function pass {
    warn $@
}

function success {
    info $@
}

## Git

function git_file_changed {
    return $(git diff HEAD --quiet --exit-code $1)
}

function git_ensure_file_unchanged {
    debug "Ensuring file '$1' unchanged"
    git_file_changed "$1" || fail "Uncommitted local changes detected to file '$1'; aborting."
    debug "File '$1' unchanged."
}

function git_ensure_file_changed {
    debug "Ensuring file '$1' changed"
    git_file_changed $1 && pass "File '$1' unchanged; aborting."
    debug "File $1 changed."
}

function git_add_single_file {
    local path=$1

    git_ensure_file_changed $path

    local relpath=$(realpath --relative-to="$DOTFILES_BASE_DIR" "$path")

    debug "Committing changes to file '$relpath"
    git reset --soft HEAD
    git add $path
    git commit -m "Updated $relpath"
    debug "Committed changes to file '$relpath'"
}

# Symlinking

function link_installed {
    local file_path=$1
    local link_path=$2

    if [ $(readlink -f "${link_path}") == "${file_path}" ]
    then
        return ${TRUE}
    else
        return ${FALSE}
    fi
}

function symlink_install {
    local file_path=$1
    local link_path=$2

    debug "Installing symlink: ${link_path}"

    if link_installed $@
    then
        pass "Symlink already installed: ${link_path}"
        return
    fi

    ln -s ${file_path} ${link_path} \
        || fail "Unable to install symlink"

    success "Symlink installed: ${link_path}"
}

function symlink_remove {
    local file_path=$1
    local link_path=$2

    debug "Removing symlink: ${link_path}"

    if ! link_installed $@
    then
        pass "Symlink is not installed: ${link_path}"
        return
    fi

    rm ${link_path} \
        || fail "Unable to remove link: ${link_path}"

    success "Symlink removed: ${link_path}"
}


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

function git_isset_excludesfile {
    if [ "$(git config --global --get core.excludesfile)" == "${GITIGNORE_GLOBALS_LINK_PATH}" ]
    then
        return ${TRUE}
    else
        return ${FALSE}
    fi
}

function git_set_excludesfile {
    debug "Setting git core.excludesfile: ${GITIGNORE_GLOBALS_LINK_PATH}"

    if git_isset_excludesfile
    then
        pass "Git core.excludesfile file is already set: ${GITIGNORE_GLOBALS_LINK_PATH}"
        return
    fi

    git config --global core.excludesfile ${GITIGNORE_GLOBALS_LINK_PATH} \
        || fail "Unable to configure git"
    success "Git core.excludesfile set: ${GITIGNORE_GLOBALS_LINK_PATH}"
}

function git_unset_excludesfile {
    debug "Unsetting git core.excludesfile"

    if ! git_isset_excludesfile
    then
        pass "Git core.excludesfile file is already unset"
        return
    fi

    git config --global --unset core.excludesfile \
        || fail "Unable to configure git"
    success "Git core.excludesfile unset"
}

function enable {
    debug "Enabling gitignore globals"
    symlink_install ${GITIGNORE_GLOBALS_DOTFILE_PATH} ${GITIGNORE_GLOBALS_LINK_PATH}
    git_set_excludesfile
    debug "Gitignore globals: Enabled"
}


function disable {
    debug "Disabling gitignore globals"
    symlink_remove ${GITIGNORE_GLOBALS_DOTFILE_PATH} ${GITIGNORE_GLOBALS_LINK_PATH}
    git_unset_excludesfile
    debug "Gitignore globals: Disabled"
}

$@


