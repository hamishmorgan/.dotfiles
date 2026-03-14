_:

{
  programs.direnv = {
    enable = true;

    # nix-direnv caches dev shell derivations as GC roots, making
    # cd-into-project near-instant instead of re-evaluating each time.
    nix-direnv.enable = true;

    # Shell integrations are enabled by default for all enabled shells.
  };
}
