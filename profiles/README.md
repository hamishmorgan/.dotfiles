# Configuration Profiles

Profiles allow you to switch between different configuration sets for different contexts.

## Available Profiles

### Personal (Default)

Full configuration with all packages.

```bash
./dot profile personal
```

### Work

Work environment with Shopify-specific configurations.

```bash
./dot profile work
```

### Minimal

Barebones setup with essential packages only.

```bash
./dot profile minimal
```

## Profile Management

### Switch Profile

```bash
./dot profile <name>
```

### List Profiles

```bash
./dot profile list
```

### Show Current Profile

```bash
./dot profile status
```

## Creating Custom Profiles

Create a new file in `profiles/` directory:

```bash
# profiles/custom.conf

# Packages to install
PROFILE_PACKAGES=(
    "git"
    "zsh"
)

# Description
PROFILE_DESCRIPTION="My custom profile"

# Optional: specific templates to enable
PROFILE_TEMPLATES=(
    "git/.gitconfig.custom.template"
)
```

Then activate it:

```bash
./dot profile custom
```

## Profile Format

Profile configuration files use bash syntax and support:

- `PROFILE_PACKAGES`: Array of package names to install
- `PROFILE_TEMPLATES`: Array of specific templates to process (optional)
- `PROFILE_DESCRIPTION`: Human-readable description

## Notes

- Switching profiles will reinstall dotfiles with the new configuration
- Previous configuration is backed up before switching
- The active profile is stored in `.active_profile`

