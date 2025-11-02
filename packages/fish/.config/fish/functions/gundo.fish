function gundo -d "Undo last git commit (keep changes)"
    git reset --soft HEAD~1
end
