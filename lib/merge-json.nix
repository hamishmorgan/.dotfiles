# Merge an attrset into a mutable JSON file during Home Manager activation.
#
# Keys in `settings` are enforced on each `make switch`; other keys already
# in the file are preserved.  Useful for tools that write their own config
# (e.g. pi's /model, /settings) but where you still want Nix to own some keys.
#
# Usage:
#   home.activation.mergePiSettings = mergeJsonFile {
#     file = "${config.home.homeDirectory}/.pi/agent/settings.json";
#     settings = { defaultProvider = "anthropic"; };
#   };
{ pkgs, lib }:

{ file, settings, after ? [ "writeBoundary" ] }:

let
  name = builtins.replaceStrings [ "/" "." ] [ "-" "-" ] (builtins.baseNameOf file);
  settingsFile = pkgs.writeText "${name}-managed" (builtins.toJSON settings);
in
lib.hm.dag.entryAfter after ''
  target="${file}"
  mkdir -p "$(dirname "$target")"
  [ -f "$target" ] || echo '{}' > "$target"
  ${pkgs.jq}/bin/jq -s '.[0] * .[1]' \
    "$target" "${settingsFile}" \
    > "$target.tmp"
  mv "$target.tmp" "$target"
''
