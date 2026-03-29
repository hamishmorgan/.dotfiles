{ config, dotfilesPath, ... }:

{
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfilesPath}/nix/niri/config.kdl";
}
