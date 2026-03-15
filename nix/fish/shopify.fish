# Shopify dev tools integration
if not set -q __HM_SHOPIFY_INIT_DONE
    # dev.sh (Shopify dev CLI) — fish doesn't source bash scripts, but
    # /opt/dev/dev.sh only sets PATH entries that tec init also covers.
    # On systems where dev.sh provides something extra, add it to
    # ~/.config/fish/conf.d/dev.fish instead.
    if test -x ~/.local/state/tec/profiles/base/current/global/init
        ~/.local/state/tec/profiles/base/current/global/init fish | source
    end
    command -q dev; and abbr -a d dev
    set -gx __HM_SHOPIFY_INIT_DONE 1
end
