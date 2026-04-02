{ pkgs, ... }:

{
  home.packages = [
    pkgs.bun
    pkgs.nodejs # needed by bun globals that ship #!/usr/bin/env node launchers (e.g. pi)
  ];

  # Ensure bun global bin is on PATH for all shells
  home.sessionPath = [ "$HOME/.cache/.bun/bin" ];

  # fish doesn't source ~/.profile, so add it explicitly
  programs.fish.shellInit = ''
    fish_add_path --path ~/.cache/.bun/bin
  '';

  home.shellAliases = {
    npx = "bunx";
    npm = "bun";
  };
}
