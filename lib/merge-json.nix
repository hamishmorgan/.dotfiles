# Home Manager module that merges Nix-managed settings into mutable JSON files.
#
# Keys in `settings` are enforced on each `make switch`; other keys already
# in the file are preserved.  Useful for tools that write their own config
# (e.g. pi's /model, /settings) but where you still want Nix to own some keys.
#
# Usage:
#   mergeJsonFiles.piSettings = {
#     file = "${config.home.homeDirectory}/.pi/agent/settings.json";
#     settings = { defaultProvider = "anthropic"; };
#   };
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.mergeJsonFiles;

  mkActivation =
    _name: value:
    let
      storeName = builtins.replaceStrings [ "/" "." ] [ "-" "-" ] (builtins.baseNameOf value.file);
      settingsFile = pkgs.writeText "${storeName}-managed" (builtins.toJSON value.settings);
    in
    lib.hm.dag.entryAfter value.after ''
      target="${value.file}"
      mkdir -p "$(dirname "$target")"
      [ -f "$target" ] || echo '{}' > "$target"
      ${pkgs.jq}/bin/jq -s '.[0] * .[1]' \
        "$target" "${settingsFile}" \
        > "$target.tmp"
      mv "$target.tmp" "$target"
    '';
in
{
  options.mergeJsonFiles = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          file = lib.mkOption {
            type = lib.types.str;
            description = "Absolute path to the JSON file to merge into.";
          };
          settings = lib.mkOption {
            type = lib.types.attrs;
            description = "Attrset to merge into the file. These keys are enforced on each switch.";
          };
          after = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "writeBoundary" ];
            description = "Activation entries this merge should run after.";
          };
        };
      }
    );
    default = { };
    description = "JSON files to merge managed settings into during activation.";
  };

  config.home.activation = lib.mapAttrs mkActivation cfg;
}
