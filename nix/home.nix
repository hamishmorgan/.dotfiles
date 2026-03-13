{ config, pkgs, username, homeDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  imports = [
    ./bat.nix
    ./git.nix
    ./ripgrep.nix
  ];
}
