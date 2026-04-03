{
  config,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./extensions.nix ];

  home = {
    packages = [
      pkgs.nodejs # pi's CLI launcher uses #!/usr/bin/env node
    ];

    # Guardrails extension config
    # https://github.com/aliou/pi-guardrails
    file.".pi/agent/extensions/guardrails.json".source = ./guardrails.json;

    activation.bunInstallPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      ${pkgs.bun}/bin/bun add -g --no-summary @mariozechner/pi-coding-agent
    '';
  };

  programs.pi.extensions = [
    "npm:@aliou/pi-guardrails"
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
