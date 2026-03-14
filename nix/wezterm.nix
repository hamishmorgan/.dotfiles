{ pkgs, ... }:

{
  home.packages = [ pkgs.wezterm ];
  home.file.".wezterm.lua".source = ./wezterm/wezterm.lua;
}
