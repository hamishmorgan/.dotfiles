# fzf fuzzy finder integration
if type -q fzf
    # Use fd for file search (faster and respects .gitignore)
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'

    # Better colors and layout
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --color=16'

    # Enable fish key bindings if available
    # Ctrl-R: command history
    # Ctrl-T: file search
    # Alt-C: directory search
    if test -f /opt/homebrew/opt/fzf/shell/key-bindings.fish
        source /opt/homebrew/opt/fzf/shell/key-bindings.fish
    end
end

