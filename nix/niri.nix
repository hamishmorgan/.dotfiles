{ dotfilesPath, ... }:

{
  # Create a direct symlink (not through nix store) so niri's
  # inotify-based live-reload works. Two-level symlinks via
  # mkOutOfStoreSymlink break inotify.
  home.activation.niriConfig = ''
    ln -sfn "${dotfilesPath}/nix/niri/config.kdl" "$HOME/.config/niri/config.kdl"
  '';
}
