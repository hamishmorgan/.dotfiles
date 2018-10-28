#!/usr/bin/env bash
set -eu

### Bash config

set -euo pipefail
IFS=$'\n\t'

### Dotfiles config

DOTFILES_LIB_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
DOTFILES_BASE_DIR=${DOTFILES_LIB_DIR}/..
DOTFILES_MODULES_DIR=${DOTFILES_BASE_DIR}/modules

### Miscellaneous constants

TRUE=0
FALSE=1
