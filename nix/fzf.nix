{ ... }:

{
  programs.fzf = {
    enable = true;

    # Use fd for file/directory search (faster, respects .gitignore)
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";

    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];

    # Shell integrations (key bindings: Ctrl-R, Ctrl-T, Alt-C) are
    # enabled by default for all enabled shells. HM sources the
    # bindings from the Nix-installed fzf package directly — no more
    # searching multiple Homebrew/system paths.
  };
}
