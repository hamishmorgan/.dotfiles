# shellcheck shell=bash
# Shopify dev tools integration

# Shopify dev
[[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]] && source /opt/dev/dev.sh

# Tec agent (Shopify Nix)
[[ -x ~/.local/state/tec/profiles/base/current/global/init ]] && [[ $- == *i* ]] && \
    eval "$(~/.local/state/tec/profiles/base/current/global/init zsh)"

