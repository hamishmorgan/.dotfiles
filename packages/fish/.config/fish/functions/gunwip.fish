function gunwip -d "Undo WIP commit"
    set -l last_commit (git log -1 --pretty=%B)

    if string match -q "WIP:*" "$last_commit"
        git reset HEAD~1
        echo "Undone WIP commit: $last_commit"
    else
        echo "Last commit is not a WIP commit"
        echo "Last commit: $last_commit"
        return 1
    end
end
