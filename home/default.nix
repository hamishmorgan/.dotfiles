{
  username,
  homeDirectory,
  ...
}:

{
  home = {
    inherit username homeDirectory;
    stateVersion = "25.11";
    sessionPath = [
      "$HOME/bin"
      "$HOME/.local/bin"
    ];
  };

  home.sessionVariables = {
    LESS = "-R -F -X -S -M";
  };

  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;

  programs.home-manager.enable = true;

  imports = [
    ./aliases.nix
    ./bash
    ./bat.nix
    ./claude
    ./delta.nix
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./fish
    ./fzf.nix
    ./gh.nix
    ./ghostty.nix
    ./git
    ./jq.nix
    ./mise.nix
    ./niri
    ./ripgrep.nix
    ./rust.nix
    ./ssh.nix
    ./system
    ./tmux.nix
    ./wezterm
    ./zed.nix
    ./zoxide.nix
    ./zsh
  ];
}
