function ls --wraps eza --description 'List directory contents with eza'
    if command -q eza
        eza --icons --group-directories-first $argv
    else
        command ls $argv
    end
end

