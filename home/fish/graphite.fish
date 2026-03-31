# Graphite (stacked PRs) — completions and abbreviations
if command -q gt
    # Cache completions (auto-loaded from completions/ by fish)
    set -l _gt_cache "$__fish_config_dir/completions/gt.fish"
    if not test -f $_gt_cache
        mkdir -p (dirname $_gt_cache)
        gt fish > $_gt_cache 2>/dev/null
        and test -s $_gt_cache
        or rm -f $_gt_cache
    end
end
