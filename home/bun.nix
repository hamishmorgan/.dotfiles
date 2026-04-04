{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.bun;

  installScript = lib.concatMapStringsSep "\n" (
    pkg: "${pkgs.bun}/bin/bun add -g --no-summary ${pkg}"
  ) cfg.globals;
in
{
  options.programs.bun = {
    globals = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "npm packages to install globally via `bun add -g` during activation.";
      example = [
        "@mariozechner/pi-coding-agent"
        "opencode-ai"
      ];
    };
  };

  config = {
    home = {
      packages = [
        pkgs.bun
        pkgs.nodejs # needed by bun globals that ship #!/usr/bin/env node launchers (e.g. pi)
      ];

      sessionPath = [
        "$HOME/.cache/.bun/bin"
      ];

      activation.bunInstallGlobals = lib.mkIf (cfg.globals != [ ]) (
        lib.hm.dag.entryAfter [ "writeBoundary" ] installScript
      );
    };

    # fish doesn't source ~/.profile, so add paths explicitly
    programs.fish.shellInit = ''
      fish_add_path --path ~/.cache/.bun/bin
    '';
  };
}
