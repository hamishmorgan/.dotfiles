# Graphite (gt) - Shopify's stacked PR workflow tool
if command -q gt
    # Cache completions for fast startup (auto-loaded from completions/ by fish)
    set -l _gt_completion_cache "$__fish_config_dir/completions/gt.fish"
    if not test -f $_gt_completion_cache
        mkdir -p (dirname $_gt_completion_cache)
        gt fish > $_gt_completion_cache 2>/dev/null
    end

    # Common abbreviations
    abbr -a gts "gt stack"
    abbr -a gtc "gt create"
    abbr -a gtsub "gt submit --no-interactive"
    abbr -a gtsy "gt sync"
    abbr -a gtre "gt restack"
    abbr -a gtco "gt checkout"
    abbr -a gtd "gt down"
    abbr -a gtu "gt up"
end
