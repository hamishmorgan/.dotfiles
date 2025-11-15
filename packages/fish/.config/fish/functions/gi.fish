# gitignore.io (gi command)
# Generate .gitignore from gitignore.io templates
function gi -d "Generate .gitignore from gitignore.io templates"
    set -l timeout "$DOTFILES_CURL_TIMEOUT"
    if test -z "$timeout"
        set timeout "30"
    end

    set -l url "https://www.toptal.com/developers/gitignore/api/$argv"

    if curl -sL --max-time "$timeout" "$url"
        return 0
    else
        echo "Error: Failed to fetch gitignore patterns (timeout or network error)" >&2
        return 1
    end
end

