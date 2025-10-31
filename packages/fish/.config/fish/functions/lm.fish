function lm --wraps eza --description 'Sort by modification time'
    if command -v eza >/dev/null
        eza --long --sort=modified --reverse --icons $argv
    else
        echo "lm: requires eza (brew install eza)" >&2
        return 1
    end
end

