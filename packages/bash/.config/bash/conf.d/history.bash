# shellcheck shell=bash
# History configuration

HISTCONTROL=ignoreboth        # Ignore duplicates and space-prefixed
HISTSIZE=10000
HISTFILESIZE=10000
shopt -s histappend           # Append to history file
shopt -s checkwinsize         # Update LINES and COLUMNS after each command

