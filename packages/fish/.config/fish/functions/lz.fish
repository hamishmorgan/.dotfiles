function lz --wraps eza --description 'Sort by size'
    if command -v eza >/dev/null
        eza --long --sort=size --reverse --icons $argv
    else
        echo "lz: requires eza (brew install eza)" >&2
        return 1
    end
end

