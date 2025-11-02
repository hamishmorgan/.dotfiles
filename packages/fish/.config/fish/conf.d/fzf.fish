# fzf fuzzy finder integration
if type -q fzf
    # Use fd for file search if available (faster and respects .gitignore)
    # Falls back to find if fd is not installed
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
    else
        set -gx FZF_DEFAULT_COMMAND 'find . -type f -not -path "*/\.git/*"'
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        set -gx FZF_ALT_C_COMMAND 'find . -type d -not -path "*/\.git/*"'
    end
    
    # Better colors and layout
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --color=16'
    
    # Enable fish key bindings if available
    # Ctrl-R: command history
    # Ctrl-T: file search
    # Alt-C: directory search
    # Check multiple common locations for fzf key bindings
    for bindings_path in \
        /opt/homebrew/opt/fzf/shell/key-bindings.fish \
        /usr/local/opt/fzf/shell/key-bindings.fish \
        /usr/share/fzf/key-bindings.fish \
        ~/.fzf/shell/key-bindings.fish
        if test -f $bindings_path
            source $bindings_path
            break
        end
    end
end

