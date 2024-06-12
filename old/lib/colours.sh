#!/usr/bin/env bash
set -eu

DOTFILES_LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_LIB_DIR}/..

source ${DOTFILES_BASE_DIR}/lib/common.sh

RED=""
GREEN=""
YELLOW=""
BLUE=""
MAGENTA=""
CYAN=""
WHITE=""
GREY=""

BG_RED=""
BG_GREEN=""
BG_YELLOW=""
BG_BLUE=""
BG_MAGENTA=""
BG_CYAN=""
BG_WHITE=""
BG_GREY=""

BOLD=""
UNDERLINE=""
NORMAL=""

if which tput >/dev/null 2>&1; then

    BOLD="$(tput bold)"
    UNDERLINE="$(tput smul)"
    NORMAL="$(tput sgr0)"

    ncolors=$(tput colors)

    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 8 ]; then
        BLACK="$(tput setaf 0)"
        RED="$(tput setaf 1)"
        GREEN="$(tput setaf 2)"
        YELLOW="$(tput setaf 3)"
        BLUE="$(tput setaf 4)"
        MAGENTA="$(tput setaf 5)"
        CYAN="$(tput setaf 6)"
        WHITE="$(tput setaf 7)"
        BG_BLACK="$(tput setab 0)"
        BG_RED="$(tput setab 1)"
        BG_GREEN="$(tput setab 2)"
        BG_YELLOW="$(tput setab 3)"
        BG_BLUE="$(tput setab 4)"
        BG_MAGENTA="$(tput setab 5)"
        BG_CYAN="$(tput setab 6)"
        BG_WHITE="$(tput setab 7)"
    fi

    if [ -t 1 ] && [ -n "$ncolors" ] && [ "$ncolors" -ge 16 ]; then
        GREY="$(tput setaf 10)"
        BG_GREY="$(tput setab 10)"
    fi
fi
