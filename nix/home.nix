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

  xdg.enable = true;

  programs.home-manager.enable = true;

  imports = [
    ./bash.nix
    ./bat.nix
    ./eza.nix
    ./fzf.nix
    ./claude.nix
    ./direnv.nix
    ./fish.nix
    ./gh.nix
    ./git.nix

    ./ripgrep.nix
    ./rust.nix
    ./system.nix
    ./tmux.nix
    ./wezterm.nix
    ./zed.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
