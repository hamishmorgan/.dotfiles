# shellcheck shell=bash
# Graphite (stacked PRs)

if command -v gt &>/dev/null; then
    gt_completion=$(gt bash 2>/dev/null)
    [[ -n "$gt_completion" ]] && source <(echo "$gt_completion")
fi

