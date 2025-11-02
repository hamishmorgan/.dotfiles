# bat (modern cat replacement with syntax highlighting)
# Ubuntu/Debian name the binary 'batcat' to avoid conflict with bacula-console-qt
if command -q batcat
    alias bat='batcat'
    set -x BAT_CONFIG_PATH "$HOME/.config/bat/config"
else if command -q bat
    set -x BAT_CONFIG_PATH "$HOME/.config/bat/config"
end

# Optional: Uncomment to replace cat with bat everywhere
# Note: This may break scripts that parse cat output
# alias cat='bat --paging=never'
