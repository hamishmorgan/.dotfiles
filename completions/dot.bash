# Dotfiles management wrapper function
d() {
    local cmd="${1:-help}"
    if (($#)); then shift; fi

    case "$cmd" in
        h|health) "$HOME/.dotfiles/dot" health "$@" ;;
        s|status) "$HOME/.dotfiles/dot" status "$@" ;;
        u|update) "$HOME/.dotfiles/dot" update "$@" ;;
        d|diff)   "$HOME/.dotfiles/dot" diff "$@" ;;
        b|backup) "$HOME/.dotfiles/dot" backup "$@" ;;
        backups)  "$HOME/.dotfiles/dot" backups "$@" ;;
        r|restore) "$HOME/.dotfiles/dot" restore "$@" ;;
        c|clean)  "$HOME/.dotfiles/dot" clean "$@" ;;
        i|install) "$HOME/.dotfiles/dot" install "$@" ;;
        security) "$HOME/.dotfiles/dot" security "$@" ;;
        cd)       builtin cd "$HOME/.dotfiles" || return ;;
        *)        "$HOME/.dotfiles/dot" "$cmd" "$@" ;;
    esac
}

# Bash completion for dot script
_dot_completion() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Complete commands
    if [[ ${COMP_CWORD} -eq 1 ]] || [[ "$prev" == -* ]]; then
        local commands="install status health update diff backup backups restore clean uninstall enable disable packages security sync pull"
        local flags="-h --help -q --quiet -v --verbose -vv"
        # Bash 3.2 compatible (no mapfile)
        COMPREPLY=()
        while IFS= read -r word; do
            COMPREPLY+=("$word")
        done < <(compgen -W "$commands $flags" -- "$cur")
    else
        # Complete flags for commands that support verbosity
        case "$prev" in
            install|update|health)
                local flags="-q --quiet -v --verbose -vv"
                COMPREPLY=()
                while IFS= read -r word; do
                    COMPREPLY+=("$word")
                done < <(compgen -W "$flags" -- "$cur")
                ;;
            enable|disable)
                # Generate package list from manifests dynamically
                local packages=""
                for pkg in "${PACKAGES[@]}"; do
                    packages="$packages $pkg"
                done
                COMPREPLY=()
                while IFS= read -r word; do
                    COMPREPLY+=("$word")
                done < <(compgen -W "$packages" -- "$cur")
                ;;
        esac
    fi
}
complete -F _dot_completion dot

# Bash completion for d function wrapper
_d_completion_bash() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    # Complete commands
    if [[ ${COMP_CWORD} -eq 1 ]] || [[ "$prev" == -* ]]; then
        local commands="h health s status u update b backup c clean i install uninstall cd"
        local flags="-h --help -q --quiet -v --verbose -vv"
        # Bash 3.2 compatible (no mapfile)
        COMPREPLY=()
        while IFS= read -r word; do
            COMPREPLY+=("$word")
        done < <(compgen -W "$commands $flags" -- "$cur")
    else
        # Complete flags for commands that support verbosity
        case "$prev" in
            i|install|u|update|h|health)
                local flags="-q --quiet -v --verbose -vv"
                COMPREPLY=()
                while IFS= read -r word; do
                    COMPREPLY+=("$word")
                done < <(compgen -W "$flags" -- "$cur")
                ;;
        esac
    fi
}
complete -F _d_completion_bash d

