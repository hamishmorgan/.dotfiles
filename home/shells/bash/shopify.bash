# Shopify dev tools integration
if [[ -z "${__HM_BASH_SHOPIFY_INIT_DONE:-}" ]]; then
  # shellcheck disable=SC1091 # managed by Shopify, not available at lint time
  [[ -f /opt/dev/dev.sh ]] && source /opt/dev/dev.sh
  [[ -x ~/.local/state/tec/profiles/base/current/global/init ]] &&
    eval "$(~/.local/state/tec/profiles/base/current/global/init bash)"
  command -v dev &>/dev/null && alias d='dev'
  # Child shells must run their own tec initialization.
  __HM_BASH_SHOPIFY_INIT_DONE=1
fi
