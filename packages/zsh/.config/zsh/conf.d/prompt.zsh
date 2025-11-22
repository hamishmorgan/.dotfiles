# shellcheck shell=bash
# Prompt configuration

autoload -Uz vcs_info
precmd() {
    vcs_info
}
setopt prompt_subst

# Git info in prompt
zstyle ':vcs_info:git:*' formats ' (%b%u%c)'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'

PROMPT='%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f %F{green}❯%f '

