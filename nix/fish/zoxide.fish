# Zoxide (smart cd replacement)
if command -q zoxide; and status is-interactive
    zoxide init fish | source
    alias cd='z'
    alias cdi='zi'
end
