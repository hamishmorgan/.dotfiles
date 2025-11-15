# Fish completion for dot command
complete -c dot -f
complete -c dot -s h -l help -d "Show help message"
complete -c dot -s v -l verbose -d "Verbose output (can be repeated)"
complete -c dot -o vv -d "Very verbose output"

# Commands
complete -c dot -n __fish_use_subcommand -a install -d "Install dotfiles using GNU Stow"
complete -c dot -n __fish_use_subcommand -a status -d "Show installation status and recent backups"
complete -c dot -n __fish_use_subcommand -a health -d "Run comprehensive diagnostics"
complete -c dot -n __fish_use_subcommand -a update -d "Update configurations and reinstall"
complete -c dot -n __fish_use_subcommand -a diff -d "Preview changes before applying"
complete -c dot -n __fish_use_subcommand -a backup -d "Create backup of existing files"
complete -c dot -n __fish_use_subcommand -a backups -d "List all available backups with details"
complete -c dot -n __fish_use_subcommand -a restore -d "Restore from backup (default: latest)"
complete -c dot -n __fish_use_subcommand -a clean -d "Clean up backup directories"
complete -c dot -n __fish_use_subcommand -a uninstall -d "Remove dotfiles symlinks"
complete -c dot -n __fish_use_subcommand -a enable -d "Enable a specific package"
complete -c dot -n __fish_use_subcommand -a disable -d "Disable a specific package"
complete -c dot -n __fish_use_subcommand -a packages -d "List all packages and their status"
complete -c dot -n __fish_use_subcommand -a security -d "Run security audit on dotfiles"
complete -c dot -n __fish_use_subcommand -a sync -d "Sync package files to system (copy-sync packages only)"
complete -c dot -n __fish_use_subcommand -a pull -d "Pull package files from system (copy-sync packages only)"
complete -c dot -n __fish_use_subcommand -a completion -d "Output shell completion script"

# Verbosity flags for install/update/health
complete -c dot -n "__fish_seen_subcommand_from install update health" -s v -l verbose -d "Verbose output"
complete -c dot -n "__fish_seen_subcommand_from install update health" -o vv -d "Very verbose output"

# Package completions (generated from manifests)
set -l dotfiles_dir "$HOME/.dotfiles"
if set -q __fish_dotfiles_dir
    set dotfiles_dir "$__fish_dotfiles_dir"
else if test -f (status --current-filename)
    set dotfiles_dir (dirname (dirname (status --current-filename)))
end

if test -d "$dotfiles_dir/packages"
    for manifest in $dotfiles_dir/packages/*/manifest.toml
        set -l pkg (basename (dirname $manifest))
        set -l desc ""
        set -l method ""
        set -l has_update false

        if test -f "$manifest"
            set desc (grep -E '^\s*description\s*=' "$manifest" 2>/dev/null | sed 's/.*=\s*["'\'']//; s/["'\'']\s*$//' | head -1)
            set method (grep -E '^\s*method\s*=' "$manifest" 2>/dev/null | sed 's/.*=\s*["'\'']//; s/["'\'']\s*$//' | head -1)
            if grep -qE '^\s*\[update\]' "$manifest" 2>/dev/null
                set has_update true
            end
        end

        if test -n "$desc"
            set desc (string replace -a '"' '\\"' "$desc")
        end

        # Enable/disable: all packages (required argument)
        complete -c dot -n "__fish_seen_subcommand_from enable disable" -a "$pkg" -d "$desc" -r

        # Sync/pull: only copy-sync packages (required argument)
        if test "$method" = copy-sync
            complete -c dot -n "__fish_seen_subcommand_from sync pull" -a "$pkg" -d "$desc (copy-sync)" -r
        end

        # Update: only packages with update sections (optional argument)
        if test "$has_update" = true
            complete -c dot -n "__fish_seen_subcommand_from update" -a "$pkg" -d "$desc (has update)"
        end
    end
end

# Backup ID completions for restore command
function __dot_complete_backups
    set -l cmd "$argv[1]"
    set -l subcommands "$argv[2]"
    set -l backup_dir_path "$dotfiles_dir/backups"

    # Calculate dotfiles_dir if not set
    if test -z "$dotfiles_dir"
        if set -q __fish_dotfiles_dir
            set backup_dir_path "$__fish_dotfiles_dir/backups"
        else if test -f (status --current-filename)
            set backup_dir_path (dirname (dirname (status --current-filename)))/backups
        else
            set backup_dir_path "$HOME/.dotfiles/backups"
        end
    end

    complete -c "$cmd" -n "__fish_seen_subcommand_from $subcommands" -a latest -d "Most recent backup" -k

    if test -d "$backup_dir_path"
        set -l timestamp_backups
        set -l numeric_backups
        set -l other_backups

        for backup_dir in $backup_dir_path/dotfiles-backup-*
            if test -d "$backup_dir"
                set -l backup_id (string replace "dotfiles-backup-" "" (basename "$backup_dir"))
                if test -n "$backup_id"
                    if string match -q -r '^[0-9]{10,}$' "$backup_id"
                        set timestamp_backups $timestamp_backups "$backup_id:$backup_id"
                    else if string match -q -r '^[0-9]+$' "$backup_id"
                        set numeric_backups $numeric_backups "$backup_id"
                    else
                        set other_backups $other_backups "$backup_id"
                    end
                end
            end
        end

        # Sort and complete timestamp backups (most recent first)
        for backup_entry in (string join \n $timestamp_backups | sort -t: -k1 -rn)
            set -l backup_id (string split ":" $backup_entry)[2]
            set -l backup_date (date -d "@$backup_id" "+%Y-%m-%d %H:%M" 2>/dev/null || date -r "$backup_id" "+%Y-%m-%d %H:%M" 2>/dev/null || echo "")
            if test -n "$backup_date"
                complete -c "$cmd" -n "__fish_seen_subcommand_from $subcommands" -a "$backup_id" -d "Backup from $backup_date" -k
            else
                complete -c "$cmd" -n "__fish_seen_subcommand_from $subcommands" -a "$backup_id" -d "Backup $backup_id" -k
            end
        end

        # Sort and complete numeric backups (descending)
        for backup_id in (string join \n $numeric_backups | sort -rn)
            complete -c "$cmd" -n "__fish_seen_subcommand_from $subcommands" -a "$backup_id" -d "Backup $backup_id" -k
        end

        # Complete other backups
        for backup_id in $other_backups
            complete -c "$cmd" -n "__fish_seen_subcommand_from $subcommands" -a "$backup_id" -d "Backup $backup_id" -k
        end
    end
end

__dot_complete_backups dot restore

# Shell name completions for completion command (required argument)
complete -c dot -n "__fish_seen_subcommand_from completion" -a bash -d "Bash shell completion" -r
complete -c dot -n "__fish_seen_subcommand_from completion" -a zsh -d "Zsh shell completion" -r
complete -c dot -n "__fish_seen_subcommand_from completion" -a fish -d "Fish shell completion" -r

# Fish completion for d function wrapper
complete -c d -f
complete -c d -s h -l help -d "Show help message"
complete -c d -s v -l verbose -d "Verbose output (can be repeated)"
complete -c d -o vv -d "Very verbose output"

# Commands with aliases
complete -c d -n __fish_use_subcommand -a h -d "health - Comprehensive diagnostics"
complete -c d -n __fish_use_subcommand -a health -d "Comprehensive diagnostics"
complete -c d -n __fish_use_subcommand -a s -d "status - Quick status check"
complete -c d -n __fish_use_subcommand -a status -d "Quick status check"
complete -c d -n __fish_use_subcommand -a u -d "update - Update and reinstall"
complete -c d -n __fish_use_subcommand -a update -d "Update and reinstall"
complete -c d -n __fish_use_subcommand -a d -d "diff - Preview changes"
complete -c d -n __fish_use_subcommand -a diff -d "Preview changes"
complete -c d -n __fish_use_subcommand -a b -d "backup - Create backup"
complete -c d -n __fish_use_subcommand -a backup -d "Create backup"
complete -c d -n __fish_use_subcommand -a backups -d "List all available backups"
complete -c d -n __fish_use_subcommand -a r -d "restore - Restore from backup"
complete -c d -n __fish_use_subcommand -a restore -d "Restore from backup"
complete -c d -n __fish_use_subcommand -a c -d "clean - Clean up old backups"
complete -c d -n __fish_use_subcommand -a clean -d "Clean up old backups"
complete -c d -n __fish_use_subcommand -a i -d "install - Install dotfiles"
complete -c d -n __fish_use_subcommand -a install -d "Install dotfiles"
complete -c d -n __fish_use_subcommand -a uninstall -d "Remove dotfiles"
complete -c d -n __fish_use_subcommand -a cd -d "Change to dotfiles directory"

# Verbosity flags for d function
complete -c d -n "__fish_seen_subcommand_from i install u update h health" -s v -l verbose -d "Verbose output"
complete -c d -n "__fish_seen_subcommand_from i install u update h health" -o vv -d "Very verbose output"

# Backup completions for d wrapper
__dot_complete_backups d "r restore"
