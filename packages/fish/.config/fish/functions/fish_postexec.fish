# ~/.config/fish/functions/fish_postexec.fish
function fish_postexec --on-event fish_postexec
    set -l last_status $status
    set -l cmd $argv[1]
    set -l duration_ms $CMD_DURATION
    set -l timestamp (date "+%Y-%m-%d %H:%M:%S")

    # Format duration nicely
    if test $duration_ms -lt 1000
        set duration_fmt "$duration_ms ms"
    else
        set duration_fmt (math -s2 "$duration_ms / 1000")" s"
    end

    # Log: timestamp | exit_code | duration | command
    echo "$timestamp | $last_status | $duration_fmt | $cmd" >> ~/.fish_command_log
end
