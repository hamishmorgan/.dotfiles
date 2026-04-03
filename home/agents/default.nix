_:

{
  imports = [
    ./claude
    ./opencode.nix
    ./pi
    ./skills.nix
  ];

  # Global agent instructions — single source for all coding agents.
  home.file.".agents/AGENTS.md".source = ./AGENTS.md;
}
