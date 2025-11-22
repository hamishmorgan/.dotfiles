# Pager configuration
# Set default pager and less options
# Only configure in interactive shells

if not status is-interactive
    return
end

# ━━━ Helper Functions ━━━

# Reuse existing helper if available, otherwise define it
if not functions -q _is_installed
    function _is_installed
        type -q "$argv[1]"
    end
end

# Check if bat is available (handles both bat and batcat)
function _is_bat_available
    type -q bat; or type -q batcat
end

# ━━━ Pager Selection ━━━

# Use bat as primary pager if available (syntax highlighting)
if _is_bat_available
    set -gx PAGER 'bat --paging=always'
    set -gx BAT_PAGER 'less -RFX'
else
    set -gx PAGER less
    # Enhanced less options (conservative set)
    set -gx LESS '-R -F -X -S -M'
end

# ━━━ File Type Detection (lesspipe) ━━━

# Enable lesspipe for better file type handling (only if not already configured)
# lesspipe sets LESSOPEN and LESSCLOSE to enable automatic decompression
if not set -q LESSOPEN
    switch (uname)
        case Linux
            if test -f /usr/bin/lesspipe; and test -x /usr/bin/lesspipe
                set -l lesspipe_output (SHELL=/bin/sh /usr/bin/lesspipe 2>/dev/null)
                if test -n "$lesspipe_output"; and test $status -eq 0
                    eval "$lesspipe_output" 2>/dev/null
                end
            else if test -f /usr/bin/lesspipe.sh; and test -x /usr/bin/lesspipe.sh
                set -l lesspipe_output (SHELL=/bin/sh /usr/bin/lesspipe.sh 2>/dev/null)
                if test -n "$lesspipe_output"; and test $status -eq 0
                    eval "$lesspipe_output" 2>/dev/null
                end
            end
        case Darwin
            # macOS: check for Homebrew installation
            if test -f /opt/homebrew/bin/lesspipe; and test -x /opt/homebrew/bin/lesspipe
                set -l lesspipe_output (SHELL=/bin/sh /opt/homebrew/bin/lesspipe 2>/dev/null)
                if test -n "$lesspipe_output"; and test $status -eq 0
                    eval "$lesspipe_output" 2>/dev/null
                end
            else if test -f /usr/local/bin/lesspipe; and test -x /usr/local/bin/lesspipe
                set -l lesspipe_output (SHELL=/bin/sh /usr/local/bin/lesspipe 2>/dev/null)
                if test -n "$lesspipe_output"; and test $status -eq 0
                    eval "$lesspipe_output" 2>/dev/null
                end
            end
    end
end
