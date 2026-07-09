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

  programs.pi.extensions = [
    "npm:pi-powerline-footer"
    "npm:pi-web-access"
  ]
  ++ lib.optionals isShopify [
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
      };
    };
  };

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
