# Editor configuration
# Set default editor for git, terminal, etc.
if type -q nvim
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx GIT_EDITOR nvim
else if type -q vim
    set -gx EDITOR vim
    set -gx VISUAL vim
    set -gx GIT_EDITOR vim
else if type -q code
    set -gx EDITOR "code --wait"
    set -gx VISUAL "code --wait"
    set -gx GIT_EDITOR "code --wait"
end

# Pager
set -gx PAGER less
set -gx LESS '-R -F -X --mouse'
