# Shopify dev tools integration
if not set -q __HM_SHOPIFY_INIT_DONE
    if test -x ~/.local/state/tec/profiles/base/current/global/init
        ~/.local/state/tec/profiles/base/current/global/init fish | source
    end
    set -gx __HM_SHOPIFY_INIT_DONE 1
end
