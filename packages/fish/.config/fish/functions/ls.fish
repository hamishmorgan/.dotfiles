function ls --wraps eza --description 'List directory contents with eza'
    if command -v eza >/dev/null
        eza --icons --group-directories-first $argv
    else
        command ls $argv
    end
end

