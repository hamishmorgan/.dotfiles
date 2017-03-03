#!/usr/bin/env bash

### Bash config

set -euo pipefail
IFS=$'\n\t'

### Dotfiles config

DOTFILES_BASE_DIR=$(dirname $(realpath -sm $0/..))

### Miscellaneous constants

TRUE=0
FALSE=1
