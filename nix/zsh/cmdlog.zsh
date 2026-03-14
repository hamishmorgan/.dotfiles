# Log every command for DX analysis
# Format matches fish in ~/.cmdlog.jsonl

__cmdlog_preexec() {
    __cmdlog_cmd="$1"
    __cmdlog_start=$EPOCHREALTIME
}

__cmdlog_precmd() {
    local exit_code=$?
    [[ -z "$__cmdlog_cmd" ]] && return
    local ts end duration_ms cmd_escaped
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    end=$EPOCHREALTIME
    duration_ms=$(( (end - __cmdlog_start) * 1000 ))
    duration_ms=${duration_ms%.*}
    cmd_escaped=$(printf '%s' "$__cmdlog_cmd" | jq -Rs .)
    echo "{\"ts\":\"$ts\",\"exit\":$exit_code,\"ms\":$duration_ms,\"cwd\":\"$PWD\",\"sid\":$$,\"cmd\":$cmd_escaped}" >> ~/.cmdlog.jsonl
    unset __cmdlog_cmd
}

add-zsh-hook preexec __cmdlog_preexec
add-zsh-hook precmd __cmdlog_precmd
