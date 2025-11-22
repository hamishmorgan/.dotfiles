# Pager configuration
# Set default pager and less options
# Only configure in interactive shells

if not status is-interactive
    return
end

# ━━━ Helper Functions ━━━

# Check if command is installed
function _is_installed
    type -q "$argv[1]"
end

# ━━━ Pager Selection ━━━

# Enhanced less options (always set for consistency)
set -gx LESS '-R -F -X -S -M'

# Use bat as primary pager if available (syntax highlighting)
if type -q bat
    set -gx PAGER 'bat --paging=always'
    set -gx BAT_PAGER 'less -RFXSM'
else if type -q batcat
    set -gx PAGER 'batcat --paging=always'
    set -gx BAT_PAGER 'less -RFXSM'
else
    set -gx PAGER less
end

# ━━━ File Type Detection (lesspipe) ━━━

# Enable lesspipe for better file type handling (only if not already configured)
# lesspipe sets LESSOPEN and LESSCLOSE to enable automatic decompression
if not set -q LESSOPEN
    # Try lesspipe or lesspipe.sh (check command availability, not specific paths)
    set -l lesspipe_cmd
    if command -v lesspipe >/dev/null 2>&1
        set lesspipe_cmd lesspipe
    else if command -v lesspipe.sh >/dev/null 2>&1
        set lesspipe_cmd lesspipe.sh
    end
    
    if test -n "$lesspipe_cmd"
        set -l lesspipe_output (SHELL=/bin/sh $lesspipe_cmd 2>/dev/null)
        if test -n "$lesspipe_output"
            eval "$lesspipe_output" 2>/dev/null
        end
    end
end
