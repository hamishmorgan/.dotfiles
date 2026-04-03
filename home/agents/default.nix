_:

{
  imports = [
    ./claude
    ./opencode.nix
    ./pi
    ./skills.nix
  ];

  # Global agent instructions — single source for all coding agents.
  # Claude reads ~/.claude/CLAUDE.md, pi reads ~/.pi/agent/AGENTS.md.
  home.file = {
    ".agents/AGENTS.md".source = ./AGENTS.md;
    ".claude/CLAUDE.md".source = ./AGENTS.md;
    ".pi/agent/AGENTS.md".source = ./AGENTS.md;
  };
}
