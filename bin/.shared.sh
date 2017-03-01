#!/usr/bin/env bash

### Bash config

set -euo pipefail
IFS=$'\n\t'

### Dotfiles config

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))

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


function git_config_isset {
    local key=$1
    local value=$2

    if [ "$(git config --global --get ${key})" == "${value}" ]
    then
        return ${TRUE}
    else
        return ${FALSE}
    fi
}

function git_config_set {
    local key=$1
    local value=$2

    debug "Setting git ${key}: ${value}"

    if git_config_isset $@
    then
        pass "Git ${key} file is already set: ${value}"
        return
    fi

    git config --global ${key} ${value} \
        || fail "Unable to configure git"
    success "Git ${key} set: ${value}"
}

function git_config_unset {
    local key=$1
    local value=$2

    debug "Unsetting git ${key}"

    if ! git_config_isset $@
    then
        pass "Git ${key}file is already unset"
        return
    fi

    git config --global --unset ${key} \
        || fail "Unable to configure git"
    success "Git ${key} unset"
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


