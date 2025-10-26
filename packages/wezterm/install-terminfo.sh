#!/bin/bash
# Install WezTerm terminfo definition
# This enables advanced terminal features like colored underlines, styled underlines, etc.

set -e

tempfile=$(mktemp)
echo "Downloading WezTerm terminfo..."
curl -s -o "$tempfile" https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo

echo "Installing terminfo to ~/.terminfo..."
tic -x -o ~/.terminfo "$tempfile"

rm "$tempfile"

echo "✓ WezTerm terminfo installed successfully!"
echo "  Now update your ~/.wezterm.lua to use: config.term = 'wezterm'"

