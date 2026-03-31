{
  lib,
  pkgs,
  isDarwin,
  ...
}:

{
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;
    settings = {
      command = lib.getExe pkgs.fish;
      font-family = "JetBrainsMono Nerd Font";
      font-size = if isDarwin then 14 else 10;
      theme = "TokyoNight";
      macos-titlebar-style = "transparent";
      background-opacity = 0.95;
      background-blur = 20;
      quit-after-last-window-closed = true;
      scrollback-limit = 10000;
      cursor-style = "bar";
      cursor-style-blink = true;
      keybind = [
        "performable:ctrl+c=copy_to_clipboard"
        "ctrl+v=paste_from_clipboard"
      ];
    };
  };
}
