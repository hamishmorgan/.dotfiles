# Pager configuration
set -gx LESS '-R -F -X -S -M'
if command -q bat
    set -gx PAGER 'bat --paging=always'
    set -gx BAT_PAGER 'less -RFXSM'
else if command -q batcat
    set -gx PAGER 'batcat --paging=always'
    set -gx BAT_PAGER 'less -RFXSM'
else
    set -gx PAGER less
end
