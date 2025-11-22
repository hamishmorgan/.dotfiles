function ll --wraps eza --description 'Long listing with git status'
    if command -q eza
        eza --long --header --icons --group-directories-first --git $argv
    else
        command ls -alF $argv
    end
end

