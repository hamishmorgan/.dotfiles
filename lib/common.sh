#!/usr/bin/env bash

### Bash config

set -euo pipefail
IFS=$'\n\t'

### Dotfiles config

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))
DOTFILES_MODULES_DIR=${DOTFILES_BASE_DIR}/modules

### Miscellaneous constants

TRUE=0
FALSE=1
