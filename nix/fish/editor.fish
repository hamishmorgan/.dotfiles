# Editor detection
# ZED_TERM survives tmux; TERM_PROGRAM doesn't
if test -n "$ZED_TERM"; or test "$TERM_PROGRAM" = zed
    set -gx EDITOR "zed --wait"
else if test -n "$VSCODE_INJECTION"; or test "$TERM_PROGRAM" = vscode
    set -gx EDITOR "code --wait"
else if command -q nvim
    set -gx EDITOR nvim
else if command -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end
set -gx VISUAL $EDITOR
set -gx GIT_EDITOR $EDITOR
