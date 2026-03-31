_:

{
  home.sessionVariables = {
    LESS = "-R -F -X -S -M";
    PAGER = "bat --paging=always";
    BAT_PAGER = "less -RFXSM";
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
      paging = "auto";
      wrap = "never";
      tabs = "4";
      map-syntax = [
        "*.conf:INI"
        ".ignore:Git Ignore"
        "*.env:Bash"
        "Dockerfile*:Dockerfile"
      ];
    };
  };
}
