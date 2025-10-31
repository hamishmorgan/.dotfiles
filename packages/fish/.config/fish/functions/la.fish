function la --wraps eza --description 'Long listing including hidden files'
    if command -v eza >/dev/null
        eza --long --all --header --icons --group-directories-first --git $argv
    else
        command ls -A $argv
    end
end

