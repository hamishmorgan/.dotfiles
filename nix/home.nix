{ config, pkgs, username, homeDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./bat.nix
    ./gh.nix
    ./git.nix
    ./gnuplot.nix
    ./ripgrep.nix
    ./rust.nix
    ./tmux.nix
    ./zed.nix
  ];
}
