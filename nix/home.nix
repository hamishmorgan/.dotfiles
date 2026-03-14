{ config, pkgs, username, homeDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
    sessionPath = [
      "$HOME/bin"
      "$HOME/.local/bin"
    ];
  };

  xdg.enable = true;

  programs.home-manager.enable = true;

  imports = [
    ./bat.nix
    ./gh.nix
    ./git.nix

    ./ripgrep.nix
    ./rust.nix
    ./tmux.nix
    ./zed.nix
    ./zsh.nix
  ];
}
