{ config, pkgs, username, homeDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./bat.nix
    ./git.nix
    ./ripgrep.nix
  ];
}
