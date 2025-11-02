# GNU Plot Package

Gnuplot plotting configuration with custom styles and terminal settings.

## Files Managed

- `.gnuplot` - Gnuplot configuration

## Features

- **Plotting configuration** - Default plot styles and settings
- **Custom color schemes** - Enhanced visualization colors
- **Terminal settings** - Output format preferences

## Installation

```bash
./dot enable gnuplot
```

## Prerequisites

Install gnuplot:

```bash
# macOS
brew install gnuplot

# Ubuntu/Debian
sudo apt install gnuplot

# CentOS/RHEL/Fedora
sudo yum install gnuplot
```

## Usage

After installation, gnuplot will use the custom configuration automatically:

```bash
gnuplot
# Configuration from ~/.gnuplot is loaded
```
