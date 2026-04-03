_:

{
  imports = [
    ./claude
    ./ollama.nix
    ./opencode.nix
    ./pi
    ./skills
    ./skills.nix
  ];

  # Global agent instructions — single source for all coding agents.
  home.file.".agents/AGENTS.md".source = ./AGENTS.md;
}
