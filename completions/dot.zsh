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

# Zsh completion for dot script
_dot_completion() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '(-h --help)'{-h,--help}'[Show help message]' \
        '(-q --quiet)'{-q,--quiet}'[Quiet mode (errors only)]' \
        '(-v --verbose)'{-v,--verbose}'[Verbose output]' \
        '-vv[Very verbose output]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            local -a commands
            commands=(
                'install:Install dotfiles using GNU Stow'
                'status:Show installation status and recent backups'
                'health:Run comprehensive diagnostics'
                'update:Update configurations and reinstall'
                'diff:Preview changes before applying'
                'backup:Create backup of existing files'
                'backups:List all available backups with details'
                'restore:Restore from backup (default: latest)'
                'clean:Clean up backup directories'
                'uninstall:Remove dotfiles symlinks'
                'enable:Enable a specific package'
                'disable:Disable a specific package'
                'packages:List all packages and their status'
                'security:Run security audit on dotfiles'
            )
            _describe 'dot command' commands
            ;;
        args)
            case $words[1] in
                install|update|health)
                    _arguments \
                        '(-q --quiet)'{-q,--quiet}'[Quiet mode]' \
                        '(-v --verbose)'{-v,--verbose}'[Verbose output]' \
                        '-vv[Very verbose output]'
                    ;;
                enable|disable)
                    # Complete with package names from manifests
                    local -a packages
                    packages=()
                    for pkg in "${PACKAGES[@]}"; do
                        local desc
                        desc=$(get_package_description "$pkg" 2>/dev/null || echo "")
                        if [[ -n "$desc" ]]; then
                            packages+=("$pkg:$desc")
                        else
                            packages+=("$pkg")
                        fi
                    done
                    _describe 'package' packages
                    ;;
                restore)
                    # Complete with available backup IDs
                    local -a backups
                    backups=('latest:Most recent backup')
                    while IFS= read -r dir; do
                        local name
                        name=$(basename "$dir")
                        local timestamp="${name#dotfiles-backup-}"
                        backups+=("$timestamp:Backup $timestamp")
                    done < <(find "$HOME/.dotfiles/backups" -type d -name "dotfiles-backup-*" 2>/dev/null | sort -r)
                    _describe 'backup' backups
                    ;;
            esac
            ;;
    esac
}
compdef _dot_completion dot

# Zsh completion for d function wrapper
_d_completion() {
    local curcontext="$curcontext" state line
    typeset -A opt_args

    _arguments -C \
        '(-h --help)'{-h,--help}'[Show help message]' \
        '(-q --quiet)'{-q,--quiet}'[Quiet mode (errors only)]' \
        '(-v --verbose)'{-v,--verbose}'[Verbose output]' \
        '-vv[Very verbose output]' \
        '1: :->command' \
        '*::arg:->args'

    case $state in
        command)
            local -a commands
            commands=(
                'h:health - Comprehensive diagnostics'
                'health:Comprehensive diagnostics'
                's:status - Quick status check'
                'status:Quick status check'
                'u:update - Update and reinstall'
                'update:Update and reinstall'
                'd:diff - Preview changes'
                'diff:Preview changes'
                'b:backup - Create backup'
                'backup:Create backup'
                'backups:List all available backups'
                'r:restore - Restore from backup'
                'restore:Restore from backup'
                'c:clean - Clean up old backups'
                'clean:Clean up old backups'
                'i:install - Install dotfiles'
                'install:Install dotfiles'
                'uninstall:Remove dotfiles'
                'cd:Change to dotfiles directory'
            )
            _describe 'dotfiles command' commands
            ;;
        args)
            case $words[1] in
                i|install|u|update|h|health)
                    _arguments \
                        '(-q --quiet)'{-q,--quiet}'[Quiet mode]' \
                        '(-v --verbose)'{-v,--verbose}'[Verbose output]' \
                        '-vv[Very verbose output]'
                    ;;
            esac
            ;;
    esac
}
compdef _d_completion d

