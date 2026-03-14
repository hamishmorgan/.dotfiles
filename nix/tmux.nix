_:

{
  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
    escapeTime = 0;
    prefix = "`";
    baseIndex = 1;
    mouse = true;
    focusEvents = true;
    historyLimit = 10000;

    extraConfig = ''
      set -ga terminal-overrides ",screen-256color*:Tc"
      set -g status-style 'bg=#333333 fg=#5eacd3'
    '';
  };
}
