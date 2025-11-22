# shellcheck shell=bash
# Pager configuration
# Set default pager and less options
# Only configure in interactive shells

[[ -o interactive ]] || return

# ━━━ Pager Selection ━━━

# Enhanced less options (always set for consistency)
export LESS='-R -F -X -S -M'

# Use bat as primary pager if available (syntax highlighting)
if command -v bat &>/dev/null; then
    export PAGER='bat --paging=always'
    export BAT_PAGER='less -RFXSM'
elif command -v batcat &>/dev/null; then
    export PAGER='batcat --paging=always'
    export BAT_PAGER='less -RFXSM'
else
    export PAGER='less'
fi

# ━━━ File Type Detection (lesspipe) ━━━

# Enable lesspipe for better file type handling (only if not already configured)
# lesspipe sets LESSOPEN and LESSCLOSE to enable automatic decompression
if [[ -z "${LESSOPEN:-}" ]]; then
    # Try lesspipe or lesspipe.sh (check command availability, not specific paths)
    lesspipe_cmd=""
    if command -v lesspipe &>/dev/null; then
        lesspipe_cmd="lesspipe"
    elif command -v lesspipe.sh &>/dev/null; then
        lesspipe_cmd="lesspipe.sh"
    fi
    
    if [[ -n "$lesspipe_cmd" ]]; then
        lesspipe_output=$(SHELL=/bin/sh "$lesspipe_cmd" 2>/dev/null)
        if [[ -n "$lesspipe_output" ]]; then
            eval "$lesspipe_output" 2>/dev/null
        fi
    fi
    unset lesspipe_cmd lesspipe_output
fi

