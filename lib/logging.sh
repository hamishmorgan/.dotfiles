#!/usr/bin/env bash
set -eu

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
        echo -e "\e[31m$@\e[0m"
    fi
}

function warn {
    if [ ${verbosity} -ge ${WARN} ]; then
        echo -e "\e[33m$@\e[0m"
    fi
}

function info {
    if [ ${verbosity} -ge ${INFO} ]; then
        echo -e "$@"
    fi
}

function debug {
    if [ ${verbosity} -ge ${DEBUG} ]; then
        echo -e "\e[2m$@\e[0m"
    fi
}

function trace {
    if [ ${verbosity} -ge ${TRACE} ]; then
        printf '  %.0s' $(seq 1 ${#FUNCNAME[@]})
        echo -e "\e[35m${FUNCNAME[1]}($@)\e[0m"
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
        echo -e "\e[32m$@\e[0m"
    fi
}
