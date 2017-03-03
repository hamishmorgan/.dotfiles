#!/usr/bin/env bash

source ${DOTFILES_BASE_DIR}/lib/git.sh

git_config_unset "core.excludesfile" "$target_path"


