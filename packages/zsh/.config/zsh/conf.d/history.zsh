# shellcheck shell=bash
# History configuration

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory          # Append to history file
setopt sharehistory           # Share history between sessions
setopt incappendhistory       # Add commands immediately
setopt histignoredups         # Ignore duplicate commands
setopt histfindnodups         # Don't show duplicates in search
setopt histreduceblanks       # Remove superfluous blanks

