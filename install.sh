#!/usr/bin/env bash
set -eu

CONFIG="install.conf.yaml"
DOTBOT_DIR="dotbot"

DOTBOT_BIN="bin/dotbot"

DOTFILES_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd "${DOTFILES_BASE_DIR}"
git submodule update --init --recursive "${DOTBOT_DIR}"

"${DOTFILES_BASE_DIR}/${DOTBOT_DIR}/${DOTBOT_BIN}" -d "${DOTFILES_BASE_DIR}" -c "${CONFIG}" "${@}"
