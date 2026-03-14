# Shared shell aliases — applied to all enabled shells (bash, zsh, fish).
# Fish also has a richer abbreviation superset in fish.nix;
# abbreviations expand inline and take precedence when typing.
{ ... }:

{
  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    c = "clear";
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
    gd = "git diff";
    glog = "git log --oneline --graph --decorate";
    gwt = "git worktree";
    gwta = "git worktree add";
    gwtl = "git worktree list";
    gwtr = "git worktree remove";
  };
}
