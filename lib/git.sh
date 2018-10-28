#!/usr/bin/env bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DIR}/..

source ${DOTFILES_BASE_DIR}/lib/common.sh
source ${DOTFILES_BASE_DIR}/lib/logging.sh

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
