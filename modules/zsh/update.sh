#!/usr/bin/env bash
set -eu

DOTFILE_ZSH_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILE_ZSH_DIR}/../..

zsh -f $ZSH/tools/upgrade.sh


