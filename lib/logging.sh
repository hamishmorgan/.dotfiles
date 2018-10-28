#!/usr/bin/env bash
set -eu

DOTFILES_LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_LIB_DIR}/..

source ${DOTFILES_BASE_DIR}/lib/colours.sh

### Logging

OFF=-1
ERROR=0
WARN=1
INFO=2
DEBUG=3
TRACE=4

verbosity=${DEBUG}

function error {
    if [ ${verbosity} -ge ${TRACE} ]; then
        echo -e "${RED}$@${NORMAL}"
    fi
}

function warn {
    if [ ${verbosity} -ge ${WARN} ]; then
        echo -e "${YELLOW}$@${NORMAL}"
    fi
}

function info {
    if [ ${verbosity} -ge ${INFO} ]; then
        echo -e "$@"
    fi
}

function debug {
    if [ ${verbosity} -ge ${DEBUG} ]; then
        echo -e "${GREY}$@${NORMAL}"
    fi
}

function trace {
    if [ ${verbosity} -ge ${TRACE} ]; then
        printf '  %.0s' $(seq 1 ${#FUNCNAME[@]})
        echo -e "${GREY}${FUNCNAME[1]}($@)${NORMAL}"
    fi
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
    if [ ${verbosity} -ge ${INFO} ]; then
        echo -e "${GREEN}$@${NORMAL}"
    fi
}
