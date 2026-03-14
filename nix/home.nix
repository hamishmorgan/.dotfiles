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

  # Runtime dependencies used by other modules
  programs.fd.enable = true; # fzf file/directory search (fzf.nix)
  programs.jq.enable = true; # command logging JSON escaping (cmdlog)

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
