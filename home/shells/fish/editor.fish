# Editor detection
if command -q nvim
    set -gx EDITOR nvim
else if command -q vim
    set -gx EDITOR vim
else
    set -gx EDITOR vi
end
set -gx VISUAL $EDITOR
set -gx GIT_EDITOR $EDITOR
