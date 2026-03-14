_:

{
  programs.zoxide = {
    enable = true;
    # Shell integrations are enabled by default for all enabled shells.
    # Provides: z, zi commands + shell hooks for directory tracking.
  };

  # Match current aliases: cd→z, cdi→zi in fish; zi alias in bash/zsh
  programs.fish.shellAbbrs = {
    cd = "z";
    cdi = "zi";
  };
}
