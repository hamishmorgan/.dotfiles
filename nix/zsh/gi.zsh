# Generate .gitignore from gitignore.io templates
gi() {
    local timeout="${DOTFILES_CURL_TIMEOUT:-30}"
    curl -sLw "\n" --max-time "$timeout" "https://www.toptal.com/developers/gitignore/api/$*" || {
        echo "Error: Failed to fetch gitignore patterns" >&2; return 1
    }
}
