{ config, isDarwin, lib, ... }:

let
  readZsh = file: builtins.readFile ./zsh/${file};
in
{
  programs.zsh = {
    enable = true;

    dotDir = "${config.xdg.configHome}/zsh";

    defaultKeymap = "emacs";

    # Directory navigation
    autocd = true;
    setOptions = [
      "AUTOPUSHD"
      "PUSHDSILENT"
      "PUSHDTOHOME"
      "PROMPT_SUBST"
    ];

    # History
    history = {
      path = "${config.home.homeDirectory}/.zsh_history";
      size = 10000;
      save = 10000;
      append = true;
      share = true;
      ignoreDups = true;
      findNoDups = true;
    };

    historySubstringSearch.enable = true;

    enableCompletion = true;

    # Plugins
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    # Aliases
    shellAliases = {
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      c = "clear";
      dot = "~/.dotfiles/dot";

      # Git
      g = "git";
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      glog = "git log --oneline --graph --decorate";
      gwt = "git worktree";
      gwta = "git worktree add";
      gwtl = "git worktree list";
      gwtr = "git worktree remove";
    };

    initContent = lib.mkMerge [
      # Completion styles (before compinit at 570)
      (lib.mkOrder 550 ''
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' menu select
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      '')

      # Shell config (one file per tool, default order 1000)
      (readZsh "prompt.zsh")
      (readZsh "eza.zsh")
      (readZsh "fzf.zsh")
      (readZsh "pager.zsh")
      (readZsh "direnv.zsh")
      (readZsh "shadowenv.zsh")
      (readZsh "zoxide.zsh")
      # Note: graphite (gt) only provides bash completions, no zsh support yet
      (readZsh "mise.zsh")
      (readZsh "rust.zsh")
      (readZsh "editor.zsh")

      # Platform (needs Nix interpolation)
      (lib.optionalString isDarwin ''
        [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
      '')

      # Shopify
      (readZsh "shopify.zsh")

      # Command logging (late, after all hooks registered)
      (lib.mkOrder 1400 (readZsh "cmdlog.zsh"))

      # Machine-specific (always last)
      # Note: tec agent auto-appends its init to .zshrc.local periodically.
      # The __HM_SHOPIFY_INIT_DONE guard in shopify.zsh won't help here since
      # .zshrc.local uses a raw eval without the guard. Just clean the file
      # when double banners appear: the init is already handled by shopify.zsh.
      (lib.mkOrder 1500 ''
        [[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
        [[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
      '')
    ];

    # Login shell (.zprofile)
    profileExtra = ''
      ${lib.optionalString isDarwin ''
        # GNU tools on macOS
        if command -v brew &> /dev/null; then
          PATH="/usr/local/opt/gnu-tar/libexec/gnubin:$PATH"
          PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
          MANPATH="$(brew --prefix coreutils)/libexec/gnuman:''${MANPATH:-}"
          export PATH MANPATH
        fi
      ''}

      export PATH="$HOME/bin:$HOME/.local/bin:$PATH"

      # Machine-specific
      [ -f ~/.zprofile.local ] && source ~/.zprofile.local

      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
    '';
  };
}
