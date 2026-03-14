{ isDarwin, lib, ... }:

let
  readBash = file: builtins.readFile ./bash/${file};
in
{
  programs.bash = {
    enable = true;

    enableCompletion = true;

    shellOptions = [
      "histappend"
      "extglob"
      "globstar"
      "checkjobs"
      "checkwinsize"
    ];

    historySize = 10000;
    historyFileSize = 10000;
    historyControl = [ "ignoreboth" ];

    shellAliases = import ./aliases.nix;

    profileExtra = ''
      ${lib.optionalString isDarwin ''
        [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
      ''}
      # Machine-specific
      [[ -f ~/.bash_profile.local ]] && source ~/.bash_profile.local
    '';

    initExtra = ''
      ${readBash "prompt.bash"}
      ${readBash "eza.bash"}
      ${readBash "fzf.bash"}
      ${readBash "pager.bash"}
      ${readBash "editor.bash"}
      ${readBash "direnv.bash"}
      ${readBash "zoxide.bash"}
      ${readBash "graphite.bash"}
      ${readBash "rust.bash"}
      ${readBash "shopify.bash"}
      ${readBash "cmdlog.bash"}

      # Machine-specific (always last)
      [[ -f ~/.bashrc.local ]] && source ~/.bashrc.local
      [[ -f "$HOME/.local/bin/env" ]] && . "$HOME/.local/bin/env"
    '';
  };
}
