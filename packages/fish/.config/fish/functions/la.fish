function la --wraps eza --description 'Long listing including hidden files'
    if command -q eza
        eza --long --all --header --icons --group-directories-first --git $argv
    else
        command ls -A $argv
    end
end

