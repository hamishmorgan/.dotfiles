function gclean -d "Delete merged git branches (interactive)"
    # Check if we're in a git repo
    if not git rev-parse --git-dir >/dev/null 2>&1
        echo "Not in a git repository"
        return 1
    end

    # Get current branch
    set -l current_branch (git branch --show-current)

    # Find merged branches (excluding current, main, master, develop)
    set -l merged_branches (git branch --merged |
        grep -v "^\*" |
        grep -v "main\|master\|develop" |
        string trim)

    if test (count $merged_branches) -eq 0
        echo "No merged branches to delete"
        return 0
    end

    echo "Merged branches that can be deleted:"
    for branch in $merged_branches
        echo "  - $branch"
    end

    read -l -P "Delete these branches? [y/N] " confirm

    if test "$confirm" = y -o "$confirm" = Y
        for branch in $merged_branches
            git branch -d $branch
            and echo "Deleted: $branch"
        end
    else
        echo Cancelled
    end
end
