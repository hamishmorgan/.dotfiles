# Homebrew setup (must run before tec init in conf.d/shopify.fish)
# brew.fish < shopify.fish alphabetically, so tec prepends after and takes precedence
if test (uname -s) = Darwin
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    else if test -x /usr/local/bin/brew
        eval (/usr/local/bin/brew shellenv)
    end
end
