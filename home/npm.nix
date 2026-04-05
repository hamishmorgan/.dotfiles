{
  config,
  isDarwin,
  lib,
  ...
}:

let
  dataDir = "${config.xdg.dataHome}/npm";
  cacheDir = "${config.xdg.cacheHome}/npm";
in
{
  config = lib.mkIf (!isDarwin) {
    home.sessionVariables = {
      NPM_CONFIG_PREFIX = dataDir;
      NPM_CONFIG_CACHE = cacheDir;
    };

    home.sessionPath = [ "${dataDir}/bin" ];

    programs.fish.shellInit = ''
      fish_add_path --path ${dataDir}/bin
    '';
  };
}
