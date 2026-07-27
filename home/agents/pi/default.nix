{
  config,
  isShopify,
  lib,
  ...
}:

{
  imports = [ ./extensions.nix ];

  # Pi reads AGENTS.md from ~/.pi/agent/
  home.file.".pi/agent/AGENTS.md".source = ../AGENTS.md;

  # Shopify supplies Pi via Nix/devx; other profiles install Pi via Bun.
  programs.bun.globals = lib.mkIf (!isShopify) [ "@mariozechner/pi-coding-agent" ];

  # Keep the default Pi surface small. Optional packages and shop-pi-fy
  # resources are installed interactively when a workflow actually needs them.
  programs.pi.extensions = lib.optionals isShopify [
    "git:git@github.com:shopify-playground/shop-pi-fy"
  ];

  # Merge managed settings into settings.json, preserving pi-managed keys.
  # Keys set here act as defaults — pi can override via /model or /settings,
  # but they reset to these values on the next `make switch`.
  mergeJsonFiles.piModels = {
    file = "${config.home.homeDirectory}/.pi/agent/models.json";
    settings = {
      providers = {
        ollama = {
          baseUrl = "http://localhost:11434/v1";
          api = "openai-completions";
          apiKey = "ollama";
          compat = {
            supportsDeveloperRole = false;
            supportsReasoningEffort = false;
          };
          models = [
            {
              id = "qwen3:8b";
              name = "Qwen 3 8B";
              input = [ "text" ];
              contextWindow = 131072;
              maxTokens = 32768;
            }
          ];
        };
      }
      // lib.optionalAttrs isShopify {
        openai.modelOverrides."gpt-5.6-sol".contextWindow = 1050000;
      };
    };
  };

  mergeJsonFiles.piSettings = {
    file = "${config.home.homeDirectory}/.pi/agent/settings.json";
    settings = {
      # Model and reasoning preferences are mutable Pi state, not Nix defaults.
      steeringMode = "all";
      quietStartup = true;
      collapseChangelog = true;
    };
  };
}
