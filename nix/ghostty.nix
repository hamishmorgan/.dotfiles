_:

{
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 10;
      theme = "Tokyo Night";
      window-decoration = false;
      background-opacity = 0.95;
      scrollback-limit = 10000;
      cursor-style = "bar";
      cursor-style-blink = true;
    };
  };
}
