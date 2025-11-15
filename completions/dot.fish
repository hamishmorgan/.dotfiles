# Fish completion for dot command
complete -c dot -f
complete -c dot -s h -l help -d "Show help message"
complete -c dot -s v -l verbose -d "Verbose output (can be repeated)"
complete -c dot -o vv -d "Very verbose output"

# Commands
complete -c dot -n "__fish_use_subcommand" -a "install" -d "Install dotfiles using GNU Stow"
complete -c dot -n "__fish_use_subcommand" -a "status" -d "Show installation status and recent backups"
complete -c dot -n "__fish_use_subcommand" -a "health" -d "Run comprehensive diagnostics"
complete -c dot -n "__fish_use_subcommand" -a "update" -d "Update configurations and reinstall"
complete -c dot -n "__fish_use_subcommand" -a "backup" -d "Create backup of existing files"
complete -c dot -n "__fish_use_subcommand" -a "backups" -d "List all available backups with details"
complete -c dot -n "__fish_use_subcommand" -a "restore" -d "Restore from backup (default: latest)"
complete -c dot -n "__fish_use_subcommand" -a "clean" -d "Clean up backup directories"
complete -c dot -n "__fish_use_subcommand" -a "uninstall" -d "Remove dotfiles symlinks"
complete -c dot -n "__fish_use_subcommand" -a "enable" -d "Enable a specific package"
complete -c dot -n "__fish_use_subcommand" -a "disable" -d "Disable a specific package"
complete -c dot -n "__fish_use_subcommand" -a "packages" -d "List all packages and their status"

# Verbosity flags for install/update/health
complete -c dot -n "__fish_seen_subcommand_from install update health" -s v -l verbose -d "Verbose output"
complete -c dot -n "__fish_seen_subcommand_from install update health" -o vv -d "Very verbose output"

# Package completions for enable/disable (generated from manifests)
# Dynamically generate completions by reading manifest files
set -l dotfiles_dir "$HOME/.dotfiles"
# Try to detect dotfiles directory from completion file location if available
if set -q __fish_dotfiles_dir
    set dotfiles_dir "$__fish_dotfiles_dir"
else if test -f (status --current-filename)
    set -l completion_file (status --current-filename)
    set dotfiles_dir (dirname (dirname "$completion_file"))
end

if test -d "$dotfiles_dir/packages"
    for manifest in $dotfiles_dir/packages/*/manifest.toml
        set -l pkg (basename (dirname $manifest))
        set -l desc ""
        # Extract description from manifest if present
        if test -f "$manifest"
            set desc (grep -E '^\s*description\s*=' "$manifest" 2>/dev/null | sed 's/.*=\s*["'\'']//; s/["'\'']\s*$//' | head -1)
        end
        if test -n "$desc"
            # Escape quotes in description
            set desc (string replace -a '"' '\\"' "$desc")
            complete -c dot -n "__fish_seen_subcommand_from enable disable" -a "$pkg" -d "$desc"
        else
            complete -c dot -n "__fish_seen_subcommand_from enable disable" -a "$pkg"
        end
    end
end

# Fish completion for d function wrapper
complete -c d -f
complete -c d -s h -l help -d "Show help message"
complete -c d -s v -l verbose -d "Verbose output (can be repeated)"
complete -c d -o vv -d "Very verbose output"

# Commands with aliases
complete -c d -n "__fish_use_subcommand" -a "h" -d "health - Comprehensive diagnostics"
complete -c d -n "__fish_use_subcommand" -a "health" -d "Comprehensive diagnostics"
complete -c d -n "__fish_use_subcommand" -a "s" -d "status - Quick status check"
complete -c d -n "__fish_use_subcommand" -a "status" -d "Quick status check"
complete -c d -n "__fish_use_subcommand" -a "u" -d "update - Update and reinstall"
complete -c d -n "__fish_use_subcommand" -a "update" -d "Update and reinstall"
complete -c d -n "__fish_use_subcommand" -a "b" -d "backup - Create backup"
complete -c d -n "__fish_use_subcommand" -a "backup" -d "Create backup"
complete -c d -n "__fish_use_subcommand" -a "backups" -d "List all available backups"
complete -c d -n "__fish_use_subcommand" -a "r" -d "restore - Restore from backup"
complete -c d -n "__fish_use_subcommand" -a "restore" -d "Restore from backup"
complete -c d -n "__fish_use_subcommand" -a "c" -d "clean - Clean up old backups"
complete -c d -n "__fish_use_subcommand" -a "clean" -d "Clean up old backups"
complete -c d -n "__fish_use_subcommand" -a "i" -d "install - Install dotfiles"
complete -c d -n "__fish_use_subcommand" -a "install" -d "Install dotfiles"
complete -c d -n "__fish_use_subcommand" -a "uninstall" -d "Remove dotfiles"
complete -c d -n "__fish_use_subcommand" -a "cd" -d "Change to dotfiles directory"

# Verbosity flags for d function
complete -c d -n "__fish_seen_subcommand_from i install u update h health" -s v -l verbose -d "Verbose output"
complete -c d -n "__fish_seen_subcommand_from i install u update h health" -o vv -d "Very verbose output"

