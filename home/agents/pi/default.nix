{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.pi;

  extensionInstalls = lib.concatMapStringsSep "\n" (
    ext: ''pi install ${ext} || echo "Warning: failed to install ${ext}" >&2''
  ) cfg.extensions;
in
{
  options.programs.pi = {
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Pi extensions to install via `pi install` during activation.";
      example = [
        "npm:@aliou/pi-guardrails"
        "git:github.com/someone/pi-thing"
      ];
    };
  };

  config = {
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

        # Install pi extensions via pi's package manager.
        # Runs after bunInstallPi to ensure pi is available.
        piInstallExtensions = lib.mkIf (cfg.extensions != [ ]) (
          lib.hm.dag.entryAfter [ "bunInstallPi" ] ''
            export PATH="${pkgs.nodejs}/bin:$HOME/.cache/.bun/bin:$HOME/.npm-global/bin:$PATH"
            export npm_config_prefix="$HOME/.npm-global"
            ${extensionInstalls}
          ''
        );
      };
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
  };
}
