# Fzf (fuzzy finder) configuration
if command -v fzf &>/dev/null; then
    if command -v fd &>/dev/null; then
        export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
        export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
    fi
    export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
    for fzf_bindings in \
        /usr/share/doc/fzf/examples/key-bindings.bash \
        /opt/homebrew/opt/fzf/shell/key-bindings.bash \
        /usr/local/opt/fzf/shell/key-bindings.bash \
        ~/.fzf/shell/key-bindings.bash; do
        # shellcheck disable=SC1090
        [[ -f "$fzf_bindings" ]] && source "$fzf_bindings" && break
    done
fi
