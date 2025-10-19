# macOS-specific fish configuration
switch $FISH_HOST_OS
    case darwin
        # macOS-specific settings

        # Homebrew setup
        if test -x /opt/homebrew/bin/brew
            eval (/opt/homebrew/bin/brew shellenv)
        else if test -x /usr/local/bin/brew
            eval (/usr/local/bin/brew shellenv)
        end

        # Add any other macOS-specific environment variables or aliases here
end

