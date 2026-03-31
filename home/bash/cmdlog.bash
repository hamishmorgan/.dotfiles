# Log every command for DX analysis
# Format matches fish/zsh in ~/.cmdlog.jsonl
#
# Uses DEBUG trap for preexec (capture command + start time) and
# PROMPT_COMMAND for precmd (log result after execution).

if [[ $- == *i* ]]; then
  __cmdlog_cmd=""
  __cmdlog_start=""

  __cmdlog_preexec() {
    # Only capture the first command in a pipeline/compound
    [[ -n "$__cmdlog_cmd" ]] && return
    __cmdlog_cmd="$BASH_COMMAND"
    __cmdlog_start=${EPOCHREALTIME:-$SECONDS}
  }

  __cmdlog_precmd() {
    local exit_code=$?
    [[ -z "$__cmdlog_cmd" ]] && return

    local ts end duration_ms cmd_escaped cwd_escaped
    ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    end=${EPOCHREALTIME:-$SECONDS}
    if [[ -n "$EPOCHREALTIME" ]]; then
      duration_ms=$(awk "BEGIN {printf \"%.0f\", ($end - $__cmdlog_start) * 1000}")
    else
      duration_ms=$(((end - __cmdlog_start) * 1000))
    fi
    cmd_escaped=$(printf '%s' "$__cmdlog_cmd" | jq -Rs .)
    cwd_escaped=$(printf '%s' "$PWD" | jq -Rs .)
    echo "{\"ts\":\"$ts\",\"exit\":$exit_code,\"ms\":$duration_ms,\"cwd\":$cwd_escaped,\"sid\":$$,\"cmd\":$cmd_escaped}" >>~/.cmdlog.jsonl

    __cmdlog_cmd=""
    __cmdlog_start=""
  }

  trap '__cmdlog_preexec' DEBUG
  PROMPT_COMMAND="__cmdlog_precmd${PROMPT_COMMAND:+;$PROMPT_COMMAND}"
fi
