_:

{
  programs.zoxide = {
    enable = true;
    # Shell integrations are enabled by default for all enabled shells.
    # Provides: z, zi commands + shell hooks for directory tracking.
  };

  # Fish abbreviations: cd→z, cdi→zi (expand inline)
  programs.fish.shellAbbrs = {
    cd = "z";
    cdi = "zi";
  };
}
