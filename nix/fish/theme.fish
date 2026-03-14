# Fish shell color theme
# Enhanced colors for better readability and visual distinction

# Syntax highlighting colors
set -g fish_color_command blue --bold
set -g fish_color_param cyan
set -g fish_color_error red --bold
set -g fish_color_quote yellow
set -g fish_color_redirection bryellow
set -g fish_color_end green
set -g fish_color_comment brblack
set -g fish_color_autosuggestion brblack
set -g fish_color_operator brmagenta
set -g fish_color_escape brcyan
set -g fish_color_option cyan

# Completion pager colors
set -g fish_pager_color_completion white
set -g fish_pager_color_description yellow
set -g fish_pager_color_prefix cyan --bold
set -g fish_pager_color_progress brwhite --background=cyan
set -g fish_pager_color_selected_background --background=brblack

# Search match highlighting
set -g fish_color_search_match --background=brblack

# Git/VCS prompt colors
set -g fish_color_cwd blue
set -g fish_color_cwd_root red
set -g fish_color_status red

# History
set -g fish_color_history_current --bold

# Valid/invalid paths
set -g fish_color_valid_path --underline

# Cancel color
set -g fish_color_cancel -r

