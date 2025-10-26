# Linux-specific fish configuration
if string match -q "linux*" $FISH_HOST_OS
    # Linux-specific settings
    # Add any Linux-specific environment variables or aliases here
    set -Ux XDG_CONFIG_HOME "$HOME/.config"
end

