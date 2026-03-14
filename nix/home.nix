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
    ./aliases.nix
    ./bash.nix
    ./bat.nix
    ./claude.nix
    ./direnv.nix
    ./eza.nix
    ./fish.nix
    ./fzf.nix
    ./gh.nix
    ./git.nix
    ./mise.nix
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
