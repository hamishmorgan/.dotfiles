{ pkgs, ... }:

{
  home.packages = [ pkgs.bun ];

  home.shellAliases = {
    npx = "bunx";
    npm = "bun";
  };
}
