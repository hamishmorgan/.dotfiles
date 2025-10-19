# Dotfiles management wrapper function
function d -d "Dotfiles management shortcut"
    set -l cmd $argv[1]

    if test (count $argv) -gt 0
        set -e argv[1]
    else
        set cmd help
    end

    switch $cmd
        case h health
            ~/.dotfiles/dot health $argv
        case s status
            ~/.dotfiles/dot status $argv
        case u update
            ~/.dotfiles/dot update $argv
        case b backup
            ~/.dotfiles/dot backup $argv
        case backups
            ~/.dotfiles/dot backups $argv
        case r restore
            ~/.dotfiles/dot restore $argv
        case c clean
            ~/.dotfiles/dot clean $argv
        case i install
            ~/.dotfiles/dot install $argv
        case cd
            builtin cd ~/.dotfiles
        case '*'
            ~/.dotfiles/dot $cmd $argv
    end
end

