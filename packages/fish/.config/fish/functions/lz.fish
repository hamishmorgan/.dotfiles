function lz --wraps eza --description 'Sort by size'
    if command -q eza
        eza --long --sort=size --reverse --icons $argv
    else
        echo "lz: requires eza (brew install eza)" >&2
        return 1
    end
end

