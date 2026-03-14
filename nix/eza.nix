{ ... }:

let
  # Extra aliases beyond what programs.eza provides (ls, ll, la, lt, lla).
  # These reference `eza` which the module aliases to include our extraOptions.
  extraAliases = {
    la = "eza -la"; # Override HM default (eza -a) to be long+all
    lta = "eza --tree --level=2 --all";
    lg = "eza -l --git-ignore";
    lm = "eza -l --sort=modified --reverse";
    lz = "eza -l --sort=size --reverse";
  };
in
{
  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
  };

  programs.bash.shellAliases = extraAliases // {
    tree = "eza --tree";
  };

  programs.zsh.shellAliases = extraAliases // {
    tree = "eza --tree";
  };

  # Fish gets tree/l1-l3 as abbreviations (expand inline, visible before executing)
  programs.fish.shellAliases = extraAliases;
  programs.fish.shellAbbrs = {
    tree = "eza --tree";
    l1 = "eza --tree --level=1";
    l2 = "eza --tree --level=2";
    l3 = "eza --tree --level=3";
  };
}
