# Pager configuration
# Set default pager and less options
# Only configure in interactive shells

if not status is-interactive
    return
end

# ━━━ Pager Selection ━━━

# Enhanced less options (always set for consistency)
set -gx LESS '-R -F -X -S -M'

# Use bat as primary pager if available (syntax highlighting)
# Use command -q to check for actual executables, not aliases/functions
if command -q bat
    set -gx PAGER 'bat --paging=always'
    set -gx BAT_PAGER 'less -RFXSM'
else if command -q batcat
    set -gx PAGER 'batcat --paging=always'
    set -gx BAT_PAGER 'less -RFXSM'
else
    set -gx PAGER less
end

# ━━━ File Type Detection (lesspipe) ━━━

# Enable lesspipe for better file type handling (only if not already configured)
# lesspipe sets LESSOPEN and LESSCLOSE to enable automatic decompression
# Note: set -l variables are automatically scoped to the block, so no cleanup needed
if not set -q LESSOPEN
    # Try lesspipe or lesspipe.sh (check command availability, not specific paths)
    set -l lesspipe_cmd
    if command -q lesspipe
        set lesspipe_cmd lesspipe
    else if command -q lesspipe.sh
        set lesspipe_cmd lesspipe.sh
    end

    if test -n "$lesspipe_cmd"
        set -l lesspipe_output (SHELL=/bin/sh $lesspipe_cmd 2>/dev/null)
        if test -n "$lesspipe_output"
            eval "$lesspipe_output" 2>/dev/null
        end
    end
end
