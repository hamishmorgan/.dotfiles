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

    # History (path defaults to dotDir/.zsh_history)
    history = {
      size = 10000;
      save = 10000;
      share = true;
      ignoreDups = true;
      findNoDups = true;
    };

    historySubstringSearch.enable = true;

    enableCompletion = true;

    # Plugins
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = lib.mkMerge [
      # Completion styles (before compinit at 570)
      (lib.mkOrder 550 ''
        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
        zstyle ':completion:*' menu select
        zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      '')

      # Shell config (one file per tool, default order 1000)
      (readZsh "prompt.zsh")
      # Note: graphite (gt) only provides bash completions, no zsh support yet
      (readZsh "rust.zsh")
      (readZsh "editor.zsh")

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
        [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
      ''}
      # Machine-specific
      [ -f ~/.zprofile.local ] && source ~/.zprofile.local
    '';
  };
}
