# Home Manager module that provides programs.pi.extensions option.
#
# Extensions are installed via `pi install` during activation, after
# pi itself is installed via bun.
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

  config.home.activation.piInstallExtensions = lib.mkIf (cfg.extensions != [ ]) (
    lib.hm.dag.entryAfter [ "bunInstallPi" ] ''
      export PATH="${pkgs.nodejs}/bin:$HOME/.cache/.bun/bin:$HOME/.npm-global/bin:$PATH"
      export npm_config_prefix="$HOME/.npm-global"
      ${extensionInstalls}
    ''
  );
}
