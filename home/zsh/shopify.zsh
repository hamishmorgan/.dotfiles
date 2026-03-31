# shellcheck shell=bash
# Shopify dev tools integration
if [[ -z "$__HM_SHOPIFY_INIT_DONE" ]]; then
  # shellcheck disable=SC1091 # managed by Shopify, not available at lint time
  [[ -f /opt/dev/dev.sh ]] && source /opt/dev/dev.sh
  [[ -x ~/.local/state/tec/profiles/base/current/global/init ]] && \
      eval "$(~/.local/state/tec/profiles/base/current/global/init zsh)"
  command -v dev &>/dev/null && alias d='dev'
  export __HM_SHOPIFY_INIT_DONE=1
fi
