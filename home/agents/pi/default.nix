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

  # Set npm global prefix to a writable location so pi's package installer
  # (which uses `npm install -g`) doesn't try to write into the Nix store.
  home.file.".npmrc".text = "prefix=~/.npm-global\n";

  home.sessionPath = [ "$HOME/.npm-global/bin" ];

  # Guardrails extension config
  # https://github.com/aliou/pi-guardrails
  home.file.".pi/agent/extensions/guardrails.json".source = ./guardrails.json;

  home.activation.bunInstallPi = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.bun}/bin/bun add -g --no-summary @mariozechner/pi-coding-agent
  '';

  # Install pi extensions via npm (pi's package manager)
  # Runs after bunInstallPi to ensure pi is available.
  home.activation.piInstallExtensions = lib.hm.dag.entryAfter [ "bunInstallPi" ] ''
    export PATH="${pkgs.nodejs}/bin:$HOME/.cache/.bun/bin:$HOME/.npm-global/bin:$PATH"
    export npm_config_prefix="$HOME/.npm-global"
    pi install npm:@aliou/pi-guardrails 2>/dev/null || true
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
