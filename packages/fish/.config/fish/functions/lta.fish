function lta --wraps eza --description 'Tree view including hidden (2 levels)'
    if command -q eza
        eza --tree --level=2 --all --icons $argv
    else
        echo "lta: requires eza (brew install eza)" >&2
        return 1
    end
end

