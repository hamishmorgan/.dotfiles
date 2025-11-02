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

**Prefix:** `` ` `` (backtick) instead of default `Ctrl-b`

**Common commands:**

- `` ` c `` - Create new window
- `` ` n `` - Next window
- `` ` p `` - Previous window
- `` ` % `` - Split horizontally
- `` ` " `` - Split vertically
- `` ` d `` - Detach session

## What Makes This Different

**Backtick prefix:** Using backtick instead of `Ctrl-b` provides:

- Easier to reach on most keyboards
- Doesn't conflict with vim/emacs bindings
- Single keypress instead of key combination
