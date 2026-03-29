{ config, dotfilesPath, ... }:

{
  home.file.".config/niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nix/niri/config.kdl";
}
