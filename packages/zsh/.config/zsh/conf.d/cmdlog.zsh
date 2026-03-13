# Log every command for DX analysis
# Matches format used by fish in ~/.cmdlog.jsonl

__cmdlog_preexec() {
    __cmdlog_cmd="$1"
    __cmdlog_start=$EPOCHREALTIME
}

__cmdlog_precmd() {
    local exit_code=$?
    
    # Skip if no command was run
    [[ -z "$__cmdlog_cmd" ]] && return
    
    local ts
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    local end=$EPOCHREALTIME
    local duration_ms
    duration_ms=$(( (end - __cmdlog_start) * 1000 ))
    duration_ms=${duration_ms%.*}  # Truncate to integer
    
    local cmd_escaped
    cmd_escaped=$(printf '%s' "$__cmdlog_cmd" | jq -Rs .)
    
    echo "{\"ts\":\"$ts\",\"exit\":$exit_code,\"ms\":$duration_ms,\"cwd\":\"$PWD\",\"sid\":$$,\"cmd\":$cmd_escaped}" >> ~/.cmdlog.jsonl
    
    unset __cmdlog_cmd
}

# Add to hook arrays (zsh native mechanism)
autoload -Uz add-zsh-hook
add-zsh-hook preexec __cmdlog_preexec
add-zsh-hook precmd __cmdlog_precmd
