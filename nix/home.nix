{ config, pkgs, ... }:

{
  # Home Manager needs these
  home.username = "hamish";
  home.homeDirectory = "/Users/hamish";
  home.stateVersion = "24.11";

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Import module configs
  imports = [
    ./git.nix
  ];
}
