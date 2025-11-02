# Graphite (gt) - Shopify's stacked PR workflow tool
if type -q gt
    # Load completions if available
    gt fish 2>/dev/null | source

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
