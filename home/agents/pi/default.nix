{ config, ... }:

{
  imports = [ ./extensions.nix ];

  # Pi reads AGENTS.md from ~/.pi/agent/
  home.file.".pi/agent/AGENTS.md".source = ../AGENTS.md;

  # Guardrails extension config
  # https://github.com/aliou/pi-guardrails
  home.file.".pi/agent/extensions/guardrails.json".source = ./guardrails.json;

  programs.bun.globals = [ "@mariozechner/pi-coding-agent" ];

  programs.pi.extensions = [
    "npm:@aliou/pi-guardrails"
    "npm:pi-powerline-footer"
  ];

  # Merge managed settings into settings.json, preserving pi-managed keys.
  # Keys set here act as defaults — pi can override via /model or /settings,
  # but they reset to these values on the next `make switch`.
  mergeJsonFiles.piSettings = {
    file = "${config.home.homeDirectory}/.pi/agent/settings.json";
    settings = {
      defaultProvider = "anthropic";
      defaultModel = "claude-opus-4-6";
      defaultThinkingLevel = "medium";
      steeringMode = "all";
      quietStartup = true;
      collapseChangelog = true;
    };
  };
}
