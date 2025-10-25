# WezTerm Configuration

WezTerm is a cross-platform terminal emulator and multiplexer.

## Installation

```bash
# macOS
brew install wezterm

# Linux
# See: https://wezfurlong.org/wezterm/installation.html
```

## Features Configured

- **Font**: JetBrainsMono Nerd Font (for eza icons)
- **Theme**: Tokyo Night
- **Opacity**: 95% with macOS blur
- **Tabs**: Hidden when only one tab, fancy tab bar
- **Splits**: CMD+D (horizontal), CMD+SHIFT+D (vertical)
- **Pane Navigation**: CMD+SHIFT+Arrows
- **Scrollback**: 10,000 lines
- **Performance**: WebGpu rendering

## Customization

Edit `~/.config/wezterm/wezterm.lua` for personal preferences.

Common customizations:

- `font_size`: Adjust text size
- `color_scheme`: Change theme (see [WezTerm Color Schemes](https://wezfurlong.org/wezterm/colorschemes/))
- `window_background_opacity`: Adjust transparency (0.0-1.0)
- `keys`: Modify keybindings

## Documentation

Full WezTerm documentation: <https://wezfurlong.org/wezterm/>
