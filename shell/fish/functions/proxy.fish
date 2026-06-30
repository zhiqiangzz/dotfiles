# Proxy helpers (port of proxy/unproxy/_dotfiles_ip_country/ippublic from
# shell/zsh/functions/network_tools.zsh).

# Detect public-IP country, caching result for 24h to avoid blocking shells.
function _dotfiles_ip_country
    require_cmds curl; or return 1

    set -l cache_base $XDG_CACHE_HOME
    test -z "$cache_base"; and set cache_base "$HOME/.cache"
    set -l cache_dir "$cache_base/dotfiles"
    set -l cache_file "$cache_dir/ip_country"
    set -l now (date +%s 2>/dev/null)

    if test -f "$cache_file"
        set -l mtime
        if test "$DOTFILES_OS" = Darwin
            set mtime (stat -f %m "$cache_file" 2>/dev/null)
        else
            set mtime (stat -c %Y "$cache_file" 2>/dev/null)
        end
        if string match -qr '^[0-9]+$' -- "$mtime"
            and string match -qr '^[0-9]+$' -- "$now"
            and test (math "$now - $mtime") -lt 86400
            set -l cached (cat "$cache_file" 2>/dev/null)
            if test -n "$cached"
                printf '%s' "$cached"
                return 0
            end
        end
    end

    if test -e "$cache_dir"; and not test -d "$cache_dir"
        return 1
    end
    mkdir -p "$cache_dir" 2>/dev/null; or return 1

    set -l country (curl -fsS --max-time 2 https://ipinfo.io/country 2>/dev/null | tr -d '[:space:]')
    if test -n "$country"
        printf '%s\n' "$country" >"$cache_file"
        printf '%s' "$country"
        return 0
    end
    return 1
end

# Set http/https/all proxy env vars. CN-aware: falls back to a local default
# when the public IP is in China and no $http_proxy_server is configured.
function proxy
    require_cmds curl; or return 1

    set -l ip_country (_dotfiles_ip_country)

    set -l http_proxy_val
    if test "$ip_country" = CN
        if set -q http_proxy_server
            set http_proxy_val $http_proxy_server
        else
            set http_proxy_val http://127.0.0.1:10808
        end
    else if set -q http_proxy_server
        set http_proxy_val $http_proxy_server
    end

    if test -z "$http_proxy_val"
        echo "[proxy] no proxy configured"
        return 0
    end

    set -l all_proxy_val
    if set -q all_proxy_server
        set all_proxy_val $all_proxy_server
    else
        set all_proxy_val (string replace 'http://' 'socks5://' -- $http_proxy_val)
    end

    for var in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
        set -gx $var $http_proxy_val
    end
    for var in all_proxy ALL_PROXY
        set -gx $var $all_proxy_val
    end
end

function unproxy
    set -e all_proxy http_proxy https_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY
end

function ippublic
    require_cmds curl; or return 1
    curl ipinfo.io
end
