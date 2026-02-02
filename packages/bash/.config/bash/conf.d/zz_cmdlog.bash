# Log every command for DX analysis
# Matches format used by fish/zsh in ~/.cmdlog.jsonl

# Don't capture until shell is fully initialized (first prompt)
__cmdlog_ready=0
__cmdlog_captured=0
__cmdlog_cmd=""
__cmdlog_start=""

__cmdlog_hook() {
    local event="$1"
    
    if [[ "$event" == "preexec" ]]; then
        # Ignore everything until shell is ready (first prompt shown)
        [[ "$__cmdlog_ready" != "1" ]] && return
        
        # Only capture the FIRST preexec after precmd reset
        [[ "$__cmdlog_captured" == "1" ]] && return
        
        __cmdlog_cmd="$BASH_COMMAND"
        __cmdlog_start=${EPOCHREALTIME:-$SECONDS}
        __cmdlog_captured=1
        
    elif [[ "$event" == "precmd" ]]; then
        local exit_code=$?
        
        # First precmd = shell ready, start capturing from next cycle
        if [[ "$__cmdlog_ready" != "1" ]]; then
            __cmdlog_ready=1
            __cmdlog_captured=0
            return
        fi
        
        # Log if we captured a command with valid timing
        if [[ "$__cmdlog_captured" == "1" && -n "$__cmdlog_cmd" && -n "$__cmdlog_start" ]]; then
            local ts end duration_ms cmd_escaped
            ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
            end=${EPOCHREALTIME:-$SECONDS}
            
            if [[ -n "$EPOCHREALTIME" ]]; then
                duration_ms=$(awk "BEGIN {printf \"%.0f\", ($end - $__cmdlog_start) * 1000}")
            else
                duration_ms=$(( (end - __cmdlog_start) * 1000 ))
            fi
            
            cmd_escaped=$(printf '%s' "$__cmdlog_cmd" | jq -Rs .)
            echo "{\"ts\":\"$ts\",\"exit\":$exit_code,\"ms\":$duration_ms,\"cwd\":\"$PWD\",\"sid\":$$,\"cmd\":$cmd_escaped}" >> ~/.cmdlog.jsonl
        fi
        
        # Reset for next command
        __cmdlog_captured=0
        __cmdlog_cmd=""
        __cmdlog_start=""
    fi
}

# EXIT handler - just flush any pending capture
__cmdlog_exit() {
    [[ "$__cmdlog_captured" == "1" ]] && __cmdlog_hook precmd
}

if [[ $- == *i* ]]; then
    if [[ -n "${__hookbook_functions+x}" ]]; then
        __hookbook_functions+=("__cmdlog_hook")
    fi
    trap '__cmdlog_exit' EXIT
fi
