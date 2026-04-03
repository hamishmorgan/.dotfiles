{
  config,
  pkgs,
  lib,
  ...
}:

{
  home = {
    packages = [
      pkgs.nodejs # pi's CLI launcher uses #!/usr/bin/env node
    ];

    # Guardrails extension config
    # https://github.com/aliou/pi-guardrails
    file.".pi/agent/extensions/guardrails.json".source = ./guardrails.json;

    activation = {
      bunInstallPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        ${pkgs.bun}/bin/bun add -g --no-summary @mariozechner/pi-coding-agent
      '';

      # Install pi extensions via npm (pi's package manager)
      # Runs after bunInstallPi to ensure pi is available.
      piInstallExtensions = lib.hm.dag.entryAfter [ "bunInstallPi" ] ''
        export PATH="${pkgs.nodejs}/bin:$HOME/.cache/.bun/bin:$HOME/.npm-global/bin:$PATH"
        export npm_config_prefix="$HOME/.npm-global"
        pi install npm:@aliou/pi-guardrails || echo "Warning: failed to install pi-guardrails" >&2
      '';
    };
  };

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
