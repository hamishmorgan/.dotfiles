# Editor configuration
# Detect which editor is running and set VISUAL/EDITOR accordingly
# Priority order:
# 1. Use in-context editor for both VISUAL and EDITOR if it exists
# 2. Set EDITOR to best terminal-compatible editor (nvim, vim, vi, nano)
# 3. Set VISUAL to best visual option (GUI preferred), fallback to EDITOR

# ━━━ Helper Functions ━━━

# Check if command is installed
function _is_installed
    type -q "$argv[1]"
end

# Get process info from PID (command or args)
function _get_process_info
    set -l pid "$argv[1]"
    set -l field "$argv[2]"

    if not type -q ps; or test -z "$pid"
        return 1
    end

    set -l output (ps -o $field= -p $pid 2>/dev/null | string trim)
    if test -z "$output"
        return 1
    end

    echo "$output"
end

# Get parent PID from a given PID
function _get_parent_pid
    set -l pid "$argv[1]"
    set -l parent_pid (_get_process_info "$pid" ppid)

    if test -z "$parent_pid"; or test "$parent_pid" = 1
        return 1
    end

    echo "$parent_pid"
end

# Check if process matches pattern (checks both command and args)
function _process_matches_pattern
    set -l pid "$argv[1]"
    set -l pattern "$argv[2]"

    set -l cmd (_get_process_info "$pid" comm)
    set -l args (_get_process_info "$pid" args)

    if test -n "$cmd"; and string match -q "*$pattern*" "$cmd"
        return 0
    end

    if test -n "$args"; and string match -q "*$pattern*" "$args"
        return 0
    end

    return 1
end

# Walk up process tree to find editor (handles nested shells)
# This is necessary because:
# - Shells can be nested (e.g., fish inside tmux inside Cursor)
# - Only checking PPID misses editors that are further up the tree
# - All three shells (fish, bash, zsh) now use process tree walking to handle nested scenarios
function _find_editor_in_process_tree
    set -l pattern "$argv[1]"
    set -l max_depth
    if test -n "$argv[2]"
        set max_depth "$argv[2]"
    else
        set max_depth 10
    end
    set -l current_pid

    if not set -q fish_pid
        return 1
    end

    set current_pid "$fish_pid"

    # Check current process first
    if _process_matches_pattern "$current_pid" "$pattern"
        echo "$current_pid"
        return 0
    end

    # Walk up the process tree
    for i in (seq $max_depth)
        set -l parent_pid (_get_parent_pid "$current_pid")
        if test -z "$parent_pid"
            return 1
        end

        if _process_matches_pattern "$parent_pid" "$pattern"
            echo "$parent_pid"
            return 0
        end

        set current_pid "$parent_pid"
    end

    return 1
end

# Check if editor is in process tree
function _is_editor_in_context
    set -l editor "$argv[1]"
    set -l pattern

    switch "$editor"
        case cursor
            # Check environment variables first
            if test -n "$CURSOR_INJECTION"; or test "$TERM_PROGRAM" = cursor
                return 0
            end
            set pattern cursor
        case code
            if test -n "$VSCODE_INJECTION"; or test "$TERM_PROGRAM" = vscode
                return 0
            end
            set pattern code
        case nvim vim
            set pattern "$editor"
        case '*'
            return 1
    end

    # Fallback: check process tree
    set -l editor_pid (_find_editor_in_process_tree "$pattern" 10)
    test -n "$editor_pid"
end

# ━━━ Editor Detection ━━━

# Detect which editor context we're running in (priority: cursor, code, nvim, vim)
function _detect_editor_context
    for editor in cursor code nvim vim
        if _is_editor_in_context "$editor"
            echo "$editor"
            return 0
        end
    end
    echo ""
end

# Check if editor is installed
function _is_editor_installed
    set -l editor "$argv[1]"
    switch "$editor"
        case cursor code nvim vim vi nano
            _is_installed "$editor"
        case '*'
            return 1
    end
end

# Find installed terminal editor in priority order
function _find_terminal_editor
    for editor in nvim vim vi nano
        if _is_installed "$editor"
            echo "$editor"
            return 0
        end
    end
    echo vi # POSIX requires vi to exist (final fallback)
end

# Resolve editor command with arguments from context
function _resolve_context_editor_command
    set -l context "$argv[1]"

    if test -z "$context"; or not _is_editor_installed "$context"
        return 1
    end

    switch "$context"
        case cursor code
            # Note: --reuse-window flag doesn't work on Linux (Cursor bug)
            # Even with the flag, Cursor creates new windows instead of reusing existing ones
            # This is a known limitation of Cursor's Linux implementation
            echo "$context --wait"
        case '*'
            echo "$context"
    end
end

# Find best visual editor (GUI preferred, then terminal)
function _find_best_visual_editor
    if _is_installed cursor
        # Note: --reuse-window flag doesn't work on Linux (Cursor bug)
        echo "cursor --wait"
    else if _is_installed code
        # VSCode typically handles workspace detection better on Linux
        echo "code --wait"
    else
        _find_terminal_editor
    end
end

# ━━━ Environment Setup ━━━

# Set VISUAL and EDITOR based on detected editor
# Accepts optional context parameter to avoid redundant detection
function _set_editor_env
    set -l context
    if test -n "$argv[1]"
        set context "$argv[1]"
    else
        set context (_detect_editor_context)
    end

    # Priority 1: Use in-context editor for both if it exists
    set -l context_cmd (_resolve_context_editor_command "$context" 2>/dev/null)
    if test -n "$context_cmd"
        # Validate that the editor command is executable
        set -l editor_cmd (string split " " -- "$context_cmd")[1]
        if type -q "$editor_cmd"
            set -gx VISUAL "$context_cmd"
            set -gx EDITOR "$context_cmd"
            return
        end
    end

    # Priority 2: Set EDITOR to best terminal-compatible editor
    set -l terminal_editor (_find_terminal_editor)
    if test -n "$terminal_editor"
        set -gx EDITOR "$terminal_editor"
    end

    # Priority 3: Set VISUAL to best visual option, fallback to EDITOR
    set -l visual_editor (_find_best_visual_editor)
    set -gx VISUAL "$visual_editor"
end

# Set editors based on context detection
# Always detect context and set appropriately, even if already set
# Context can change (e.g., switching between terminal and Cursor's integrated terminal)
# so we re-detect to ensure VISUAL/EDITOR match the current environment
# Use _set_editor_env to handle all context detection and environment variable setting
_set_editor_env

# GIT_EDITOR defaults to EDITOR
if test -z "$GIT_EDITOR"
    set -gx GIT_EDITOR "$EDITOR"
end

# ━━━ User Functions ━━━

# Edit file with EDITOR
# Handles EDITOR values that contain arguments (e.g., "cursor --wait")
# Uses eval to properly handle paths with spaces and complex commands
function e --description "Edit file with EDITOR"
    set -l editor "$EDITOR"

    # Fallback to terminal editor if EDITOR not set
    if test -z "$editor"
        set editor (_find_terminal_editor)
    end

    # Validate editor command exists (extract command name, ignore args)
    set -l editor_cmd (string split " " -- "$editor")[1]
    if not type -q "$editor_cmd"
        echo "Error: Editor command not found: $editor_cmd" >&2
        return 1
    end

    # Use eval to properly handle EDITOR with arguments and paths containing spaces
    # $argv is a fish array and expands correctly, handling filenames with spaces
    eval "$editor" $argv
end

# Edit file with EDITOR (alias of e)
function v --description "Edit file with EDITOR"
    e $argv
end
