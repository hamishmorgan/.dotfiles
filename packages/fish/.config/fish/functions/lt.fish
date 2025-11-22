function lt --wraps eza --description 'Tree view (2 levels)'
    if command -q eza
        eza --tree --level=2 --icons $argv
    else
        echo "lt: requires eza (brew install eza)" >&2
        return 1
    end
end

