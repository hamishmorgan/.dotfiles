{ config, ... }:

{
  imports = [ ./extensions.nix ];

  # Guardrails extension config
  # https://github.com/aliou/pi-guardrails
  home.file.".pi/agent/extensions/guardrails.json".source = ./guardrails.json;

  programs.bun.globals = [
    "@mariozechner/pi-coding-agent"
    "typescript" # needed at runtime by pi-lens (mispackaged as devDependency)
  ];

  programs.pi.extensions = [
    "npm:@aliou/pi-guardrails"
    "npm:pi-lens"
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
    };
  };
}
