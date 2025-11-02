function rgf -d "Search code with ripgrep and fzf, open in editor"
    # Require at least one search term
    if test (count $argv) -eq 0
        echo "Usage: rgf <search-term> [rg-options]"
        return 1
    end

    # Use ripgrep to search, pipe to fzf for interactive selection
    set -l result (rg --color=always --line-number --no-heading --smart-case $argv |
        fzf --ansi \
            --color 'hl:-1:underline,hl+:-1:underline:reverse' \
            --delimiter ':' \
            --preview 'bat --color=always {1} --highlight-line {2}' \
            --preview-window 'up,60%,border-bottom,+{2}+3/3,~3')

    # If user selected a result, open in editor
    if test -n "$result"
        set -l file (echo $result | cut -d: -f1)
        set -l line (echo $result | cut -d: -f2)

        # Use EDITOR if set, otherwise try common editors
        if test -n "$EDITOR"
            $EDITOR +$line $file
        else if type -q nvim
            nvim +$line $file
        else if type -q vim
            vim +$line $file
        else if type -q code
            code --goto $file:$line
        else
            echo "Opened: $file:$line"
            echo "Set \$EDITOR to open automatically"
        end
    end
end

