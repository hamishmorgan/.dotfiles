{ ... }:

{
  programs.fzf = {
    enable = true;

    # Use fd for file/directory search (faster, respects .gitignore).
    # fd's global config (fd.nix) already sets --hidden and ignores.
    defaultCommand = "fd --type f --follow";
    fileWidgetCommand = "fd --type f --follow";
    changeDirWidgetCommand = "fd --type d --follow";

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
