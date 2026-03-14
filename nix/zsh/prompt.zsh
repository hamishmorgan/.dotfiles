# Prompt with git info via vcs_info
autoload -Uz vcs_info add-zsh-hook
add-zsh-hook precmd vcs_info
zstyle ':vcs_info:git:*' formats ' (%b%u%c)'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
PROMPT='%F{blue}%~%f%F{yellow}${vcs_info_msg_0_}%f %F{green}❯%f '
