# shellcheck shell=bash
# shellcheck disable=SC1036,SC1073,SC1072,SC1009
# SC1036,SC1073,SC1072,SC1009: Zsh glob qualifiers for completion caching
# Completion system configuration

autoload -Uz compinit

# Cache completions for 24 hours for faster startup
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# Better completion menu
zstyle ':completion:*' menu select
# Color completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

