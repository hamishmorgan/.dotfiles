#!/usr/bin/env bash
set -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DIR}/..

source ${DOTFILES_BASE_DIR}/lib/common.sh
source ${DOTFILES_BASE_DIR}/lib/logging.sh

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

    if [ $(readlink -f "${target}") == $(readlink -f "${source}") ]
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

    ln -s ${target} ${source} \
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

    rm ${source} \
        || fail "Unable to remove link: $source -> $target"

    success "Symlink removed: $source -> $target"
}

