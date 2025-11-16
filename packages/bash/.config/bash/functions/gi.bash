# shellcheck shell=bash
# gitignore.io function

gi() {
  local timeout="${DOTFILES_CURL_TIMEOUT:-30}"
  local url="https://www.toptal.com/developers/gitignore/api/$*"
  if curl -sLw "\n" --max-time "$timeout" "$url"; then
    return 0
  else
    echo "Error: Failed to fetch gitignore patterns (timeout or network error)" >&2
    return 1
  fi
}

