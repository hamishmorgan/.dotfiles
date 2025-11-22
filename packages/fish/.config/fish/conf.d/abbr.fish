# Abbreviations - expand inline when you press space
# Unlike aliases, you see the full command before executing

# ━━━ Git Shortcuts ━━━
abbr -a g git
abbr -a ga "git add"
abbr -a gaa "git add --all"
abbr -a gap "git add --patch"
abbr -a gc "git commit"
abbr -a gcm "git commit -m"
abbr -a gca "git commit --amend"
abbr -a gcan "git commit --amend --no-edit"
abbr -a gp "git push"
abbr -a gpf "git push --force-with-lease"
abbr -a gl "git pull"
abbr -a gf "git fetch"
abbr -a gfa "git fetch --all --prune"
abbr -a gd "git diff"
abbr -a gds "git diff --staged"
abbr -a gs "git status"
abbr -a gss "git status --short"
abbr -a gco "git checkout"
abbr -a gcb "git checkout -b"
abbr -a gb "git branch"
abbr -a gba "git branch --all"
abbr -a gbd "git branch --delete"
abbr -a gbD "git branch --delete --force"
abbr -a glog "git log --oneline --graph --decorate"
abbr -a gloga "git log --oneline --graph --decorate --all"
abbr -a gsh "git show"
abbr -a gst "git stash"
abbr -a gstp "git stash pop"
abbr -a gstl "git stash list"
abbr -a gr "git reset"
abbr -a grh "git reset --hard"
abbr -a grs "git reset --soft"
abbr -a grb "git rebase"
abbr -a grbi "git rebase --interactive"
abbr -a grbc "git rebase --continue"
abbr -a grba "git rebase --abort"
abbr -a gcp "git cherry-pick"
abbr -a gcpc "git cherry-pick --continue"
abbr -a gcpa "git cherry-pick --abort"
abbr -a gwt "git worktree"
abbr -a gwta "git worktree add"
abbr -a gwtl "git worktree list"
abbr -a gwtr "git worktree remove"
abbr -a gwtp "git worktree prune"

# ━━━ Navigation ━━━
abbr -a .. "cd .."
abbr -a ... "cd ../.."
abbr -a .... "cd ../../.."
abbr -a ..... "cd ../../../.."

# ━━━ Common Commands ━━━
abbr -a c clear
# e and v are defined as functions in editor.fish to use EDITOR with fallback
abbr -a mkd "mkdir -p"

# ━━━ eza (modern ls) ━━━
if type -q eza
    abbr -a tree "eza --tree"
    abbr -a l1 "eza --tree --level=1"
    abbr -a l2 "eza --tree --level=2"
    abbr -a l3 "eza --tree --level=3"
end

# ━━━ Shopify dev shortcuts ━━━
if type -q dev
    abbr -a d dev
    abbr -a ds "dev style"
    abbr -a dt "dev test"
    abbr -a dc "dev console"
    abbr -a du "dev up"
    abbr -a ddn "dev down"
    abbr -a dr "dev reset"
end

# ━━━ Docker (if you use it) ━━━
if type -q docker
    abbr -a dk docker
    abbr -a dkps "docker ps"
    abbr -a dkpsa "docker ps -a"
    abbr -a dki "docker images"
    abbr -a dkrm "docker rm"
    abbr -a dkrmi "docker rmi"
end

# ━━━ Process Management ━━━
if type -q procs
    abbr -a ps procs
end

if type -q btop
    abbr -a top btop
else if type -q htop
    abbr -a top htop
end

# ━━━ Dotfiles ━━━
abbr -a dot ~/.dotfiles/dot
abbr -a dotcd "cd ~/.dotfiles"
