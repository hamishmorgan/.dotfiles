#!/usr/bin/env bash

### Bash config

set -euo pipefail
IFS=$'\n\t'

### Dotfiles config

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))

### Global gitignore config

GITIGNORE_GLOBALS_FILENAME=.gitignore-globals
GITIGNORE_GLOBALS_TYPES='vim,netbeans,jetbrains,eclipse,linux'

### Logging

function error {
    echo -e "\e[31mERROR: $@\e[0m"
}

function warn {
    echo -e "\e[33mWARN: $@\e[0m"
}

function info {
    echo -e "\e[32mINFO: $@\e[0m"
}

function debug {
    echo -e "\e[2mDEBUG: $@\e[0m"
}

## Exit status

function fail {
    error $@
    exit 1
}


function pass {
    warn $@
    exit 0
}

function success {
    info $@
    exit 0
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

function update {
    GITIGNORE_GLOBALS_PATH=$DOTFILES_BASE_DIR/$GITIGNORE_GLOBALS_FILENAME

    debug "Updating gitignore globals file '$GITIGNORE_GLOBALS_PATH'."

    git_ensure_file_unchanged $GITIGNORE_GLOBALS_PATH

    download_gitignore $GITIGNORE_GLOBALS_TYPES $GITIGNORE_GLOBALS_PATH

    git_add_single_file $GITIGNORE_GLOBALS_PATH 

    success "Done; gitignore globals file '$GITIGNORE_GLOBALS_PATH' updated."
}

$@


