# shellcheck shell=bash
# Pager configuration
export LESS='-R -F -X -S -M'
if command -v bat &>/dev/null; then
    export PAGER='bat --paging=always'
    export BAT_PAGER='less -RFXSM'
elif command -v batcat &>/dev/null; then
    export PAGER='batcat --paging=always'
    export BAT_PAGER='less -RFXSM'
else
    export PAGER='less'
fi
