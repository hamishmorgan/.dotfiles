# Tmux Package

Tmux terminal multiplexer configuration with custom key bindings.

## Files Managed

- `.tmux.conf` - Tmux configuration

## Features

- **Custom key bindings** - Prefix key: backtick (`` ` ``)
- **Mouse support** - Click, scroll, and resize panes
- **Custom status bar** - Session info and system stats
- **Base index: 1** - Windows and panes start at 1 (not 0)
- **Vim-style navigation** - Familiar keybindings

## Installation

```bash
./dot enable tmux
```

## Key Bindings

**Prefix:** `` ` `` (backtick, easier than `Ctrl-b`)

**Common:** `` ` c `` new window, `` ` n/p `` next/prev, `` ` %/" `` split, `` ` d `` detach
