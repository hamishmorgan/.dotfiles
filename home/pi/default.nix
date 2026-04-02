{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Settings merged into ~/.pi/agent/settings.json on each `make switch`.
  # Pi-managed keys (lastChangelogVersion, etc.) are preserved.
  # Keys set here act as defaults — pi can override via /model or /settings,
  # but they reset to these values on the next `make switch`.
  managedSettings = {
    defaultProvider = "anthropic";
    defaultModel = "claude-opus-4-6";
    defaultThinkingLevel = "medium";
    steeringMode = "all";
  };

  managedSettingsJson = pkgs.writeText "pi-managed-settings.json" (builtins.toJSON managedSettings);
in
{
  home.packages = [
    pkgs.nodejs # pi's CLI launcher uses #!/usr/bin/env node
  ];

  home.file = {
    # Read-only config that pi doesn't modify
    # ".pi/agent/AGTENTS.md".source = ./AGENTS.md;
    # ".pi/agent/prompts/review.md".source = ./prompts/review.md;
    # ".pi/agent/skills/my-skill".source = ./skills/my-skill;
  };

  home.activation.bunInstallPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bun}/bin/bun add -g --no-summary @mariozechner/pi-coding-agent
  '';

  # Merge managed settings into settings.json, preserving pi-managed keys
  home.activation.mergePiSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS_FILE="${config.home.homeDirectory}/.pi/agent/settings.json"
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    [ -f "$SETTINGS_FILE" ] || echo '{}' > "$SETTINGS_FILE"
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' \
      "$SETTINGS_FILE" "${managedSettingsJson}" \
      > "''${SETTINGS_FILE}.tmp"
    mv "''${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
  '';
}
