# shellcheck shell=bash
# Shopify development tools

# Shopify dev alias
alias d='dev'

# Shopify dev script
[[ -f /opt/dev/dev.sh ]] && [[ $- == *i* ]] && source /opt/dev/dev.sh

# Tec agent (Shopify Nix)
[[ -x ~/.local/state/tec/profiles/base/current/global/init ]] && [[ $- == *i* ]] && \
    eval "$(~/.local/state/tec/profiles/base/current/global/init bash)"

