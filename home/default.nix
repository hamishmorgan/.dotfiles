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

  home.shellAliases = {
    ".." = "cd ..";
    "..." = "cd ../..";
    "...." = "cd ../../..";
    c = "clear";
  };

  nixpkgs.config.allowUnfree = true;

  xdg.enable = true;

  programs.home-manager.enable = true;

  imports = [
    ./agents
    ./bat.nix
    ./bun.nix
    ./delta.nix
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./fzf.nix
    ./gh.nix
    ./git
    ./jq.nix
    ./mise.nix
    ./niri
    ./ripgrep.nix
    ./rust.nix
    ./shells
    ./ssh.nix
    ./system
    ./terminals
    ./zed.nix
    ./zoxide.nix
  ];
}
