{ username, homeDirectory, ... }:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
    sessionPath = [
      "$HOME/bin"
      "$HOME/.local/bin"
    ];
  };

  # Static environment variables — applied to all shells via hm-session-vars.
  # bat is always installed (bat.nix), so no runtime detection needed.
  home.sessionVariables = {
    LESS = "-R -F -X -S -M";
    PAGER = "bat --paging=always";
    BAT_PAGER = "less -RFXSM";
  };

  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;

  programs.home-manager.enable = true;

  imports = [
    ./aliases.nix
    ./bash.nix
    ./bat.nix
    ./claude.nix
    ./delta.nix
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./fish.nix
    ./fzf.nix
    ./gh.nix
    ./ghostty.nix
    ./git.nix
    ./jq.nix
    ./mise.nix
    ./ripgrep.nix
    ./rust.nix
    ./ssh.nix
    ./system.nix
    ./tmux.nix
    ./wezterm.nix
    ./zed.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
