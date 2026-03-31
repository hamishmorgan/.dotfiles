{
  lib,
  pkgs,
  dotfilesPath,
  ...
}:

lib.mkIf pkgs.stdenv.isLinux {
  # Create a direct symlink (not through nix store) so niri's
  # inotify-based live-reload works. Two-level symlinks via
  # mkOutOfStoreSymlink break inotify.
  home.activation.niriConfig = ''
    ln -sfn "${dotfilesPath}/home/niri/config.kdl" "$HOME/.config/niri/config.kdl"
  '';

  home.pointerCursor = {
    name = "phinger-cursors-light";
    package = pkgs.phinger-cursors;
    size = 32;
    gtk.enable = true;
    x11.enable = true;
  };
}
