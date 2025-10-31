-- WezTerm configuration
-- Cross-platform terminal emulator
-- https://wezfurlong.org/wezterm/

local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Font configuration with Nerd Font for icons
-- config.font = wezterm.font 'JetBrainsMono Nerd Font'
config.font_size = 10.0

-- Color scheme
-- Try these built-in themes: 'Afterglow', 'BatDark', 'Blazer', 'Builtin Dark'
-- Or visit https://wezfurlong.org/wezterm/colorschemes/ for full list
config.color_scheme = 'Tokyo Night'

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.95
config.macos_window_background_blur = 20

-- Tab bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true

-- Scrollback
config.scrollback_lines = 10000

-- Performance
config.front_end = 'WebGpu'

-- Terminal type (install with install-terminfo.sh first)
config.term = 'wezterm' -- Comment out if you have not run install-terminfo.sh

-- Cursor
config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 500

-- Exit behavior
config.exit_behavior = 'CloseOnCleanExit'
config.window_close_confirmation = 'NeverPrompt'

-- Key bindings (cross-platform using SUPER)
-- SUPER maps to: CMD on macOS, Windows/Super on Linux, Windows key on Windows
config.keys = {
  -- Split panes
  {
    key = 'd',
    mods = 'SUPER',
    action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' },
  },
  {
    key = 'd',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' },
  },
  -- Navigate panes
  {
    key = 'LeftArrow',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Left',
  },
  {
    key = 'RightArrow',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Right',
  },
  {
    key = 'UpArrow',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Up',
  },
  {
    key = 'DownArrow',
    mods = 'SUPER|SHIFT',
    action = wezterm.action.ActivatePaneDirection 'Down',
  },
}

-- Platform-specific settings (macOS only for blur)
if wezterm.target_triple == 'x86_64-apple-darwin' or wezterm.target_triple == 'aarch64-apple-darwin' then
  -- macOS specific settings
  config.send_composed_key_when_left_alt_is_pressed = false
  config.send_composed_key_when_right_alt_is_pressed = true
end

return config
