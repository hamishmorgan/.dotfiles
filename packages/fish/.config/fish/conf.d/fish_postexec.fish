# Log every command for DX analysis
function fish_postexec --on-event fish_postexec
    set -l ts (date -u +"%Y-%m-%dT%H:%M:%SZ")
    set -l cmd_escaped (printf '%s' $argv[1] | jq -Rs .)
    echo "{\"ts\":\"$ts\",\"exit\":$status,\"ms\":$CMD_DURATION,\"cwd\":\"$PWD\",\"sid\":$fish_pid,\"cmd\":$cmd_escaped}" >> ~/.cmdlog.jsonl
end
