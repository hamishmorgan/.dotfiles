# shellcheck shell=zsh
# Graphite (stacked PRs) integration

if command -v gt &>/dev/null; then
    local gt_completion
    gt_completion=$(gt zsh 2>/dev/null) && [[ -n "$gt_completion" ]] && source <(echo "$gt_completion")
fi

