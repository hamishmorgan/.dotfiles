# Home Manager module that provides programs.pi.extensions option.
#
# Package sources are declared in settings.json. Pi installs missing packages
# during startup; package updates remain an explicit `pi update --extensions`.
#
# Usage:
#   programs.pi.extensions = [
#     "npm:pi-web-access"
#     "git:github.com/someone/pi-thing"
#   ];
{
  config,
  lib,
  ...
}:

let
  cfg = config.programs.pi;
in
{
  options.programs.pi = {
    extensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Pi package sources to declare in settings.json.";
      example = [
        "npm:pi-web-access"
        "git:github.com/someone/pi-thing"
      ];
    };
  };

  config = lib.mkIf (cfg.extensions != [ ]) {
    # Keep settings.json packages in sync with the declared sources. Pi installs
    # missing packages on startup without reinstalling them on every switch.
    mergeJsonFiles.piExtensions = {
      file = "${config.home.homeDirectory}/.pi/agent/settings.json";
      settings = {
        packages = cfg.extensions;
      };
    };
  };
}
