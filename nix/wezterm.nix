{ ... }:

{
  # Use home.file instead of programs.wezterm — the system-installed wezterm
  # reads ~/.wezterm.lua, not the XDG path the HM module generates.
  home.file.".wezterm.lua".source = ./wezterm/wezterm.lua;
}
