{ ... }:

{
  # Claude Code config — only manage the two config files.
  # ~/.claude/ contains runtime data (history, projects, cache) that Claude
  # Code manages itself, so we use home.file for individual files only.
  home.file = {
    ".claude/settings.json".source = ./claude/settings.json;
    ".claude/CLAUDE.md".source = ./claude/CLAUDE.md;
  };
}
