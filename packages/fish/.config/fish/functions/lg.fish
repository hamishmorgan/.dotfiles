function lg --wraps eza --description 'Git-aware listing'
    if command -v eza >/dev/null
        eza --long --git --git-ignore --icons $argv
    else
        echo "lg: requires eza (brew install eza)" >&2
        return 1
    end
end

