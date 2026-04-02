{ pkgs, ... }:

{
  home.packages = [
    pkgs.bun
    pkgs.nodejs # needed by bun globals that ship #!/usr/bin/env node launchers (e.g. pi)
  ];

  # Set npm global prefix to a writable location so tools that invoke
  # `npm install -g` (e.g. pi's package manager) don't try to write
  # into the read-only Nix store.
  home.file.".npmrc".text = "prefix=~/.npm-global\n";

  home.sessionPath = [
    "$HOME/.cache/.bun/bin"
    "$HOME/.npm-global/bin"
  ];

  # fish doesn't source ~/.profile, so add paths explicitly
  programs.fish.shellInit = ''
    fish_add_path --path ~/.cache/.bun/bin
    fish_add_path --path ~/.npm-global/bin
  '';

  home.shellAliases = {
    npx = "bunx";
    npm = "bun";
  };
}
