# Home Manager module that provides programs.pi.extensions option.
#
# Extensions are installed via `pi install` during activation, after
# pi itself is installed via bun. The `packages` key in settings.json
# is also enforced, so removed extensions are cleaned up on switch.
#
# Usage:
#   programs.pi.extensions = [
#     "npm:@aliou/pi-guardrails"
#     "git:github.com/someone/pi-thing"
#   ];
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.programs.pi;

  extensionInstalls = lib.concatMapStringsSep "\n" (
    ext:
    ''echo "Installing ${ext}"; pi install ${ext} >/dev/null 2>&1 || echo "Warning: failed to install ${ext}" >&2''
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

  config = lib.mkIf (cfg.extensions != [ ]) {
    home.activation.piInstallExtensions = lib.hm.dag.entryAfter [ "bunInstallGlobals" ] ''
      export PATH="${pkgs.nodejs}/bin:$HOME/.cache/.bun/bin:$HOME/.npm-global/bin:$PATH"
      export npm_config_prefix="$HOME/.npm-global"
      ${extensionInstalls}
    '';

    # Keep settings.json packages list in sync with declared extensions.
    # This removes extensions from settings that are no longer declared.
    mergeJsonFiles.piExtensions = {
      file = "${config.home.homeDirectory}/.pi/agent/settings.json";
      settings = {
        packages = cfg.extensions;
      };
      after = [ "piInstallExtensions" ];
    };
  };
}
