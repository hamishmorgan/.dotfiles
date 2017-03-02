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

function _link_infer_target {
    case $# in
        1) echo $HOME/$(basename $1);;
        2) echo $2;;
        *) fail "Expected either 1 or 2 arguments, but found $#: $@";;
    esac
}

function _link_infer_source {
    case $# in
        1) echo ${DOTFILES_BASE_DIR}/$(basename $1);;
        2) echo $1;;
        *) fail "Expected either 1 or 2 arguments, but found $#: $@";;
    esac
}

function link_installed {
    local source=$(_link_infer_source $@)
    local target=$(_link_infer_target $@)

    if [ $(readlink -f "${target}") == "${source}" ]
    then
        return ${TRUE}
    else
        return ${FALSE}
    fi
}

function symlink_enable {
    local source=$(_link_infer_source $@)
    local target=$(_link_infer_target $@)

    debug "Installing symlink: $source -> $target"

    if link_installed $@
    then
        pass "Symlink already installed: $source -> $target"
        return
    fi

    ln -s ${source} ${target} \
        || fail "Unable to install symlink"

    success "Symlink installed: $source -> $target"
}

function symlink_disable {
    local source=$(_link_infer_source $@)
    local target=$(_link_infer_target $@)

    debug "Removing symlink: $source -> $target"

    if ! link_installed $@
    then
        pass "Symlink is not installed: $source -> $target"
        return
    fi

    rm ${target} \
        || fail "Unable to remove link: $source -> $target"

    success "Symlink removed: $source -> $target"
}


## Hooks

function run_hook_if_exists {
    local hook=$1
    if [ -f "${hook}" ]; then
        debug "Running hook: ${hook}"
        . "${hook}"
    fi
}

##

function list-modules {
    cat ${DOTFILES_BASE_DIR}/modules
}

function list-dotfiles {
    local module=$1
    cat ${DOTFILES_BASE_DIR}/${module}/dotfiles
}
