# Proxy helpers (port of proxy/unproxy/ippublic from
# shell/zsh/functions/network_tools.zsh).
#
# Single source of truth is ~/.config/proxychains.conf (a proxychains-ng config).
# `proxy` parses its first [ProxyList] entry into http_proxy/https_proxy/all_proxy;
# `prox` runs a single command through proxychains-ng using the same file.

# Path to the shared proxychains-ng config (echoed so both functions agree).
function _proxychains_conf
    echo "$HOME/.config/proxychains.conf"
end

# Write the default proxychains-ng config template to $argv[1]. Keep in sync with
# the seed proxychains.conf in the docker-dev repo.
function _proxychains_write_template
    set -l path $argv[1]
    mkdir -p (dirname "$path") 2>/dev/null
    printf '%s\n' \
        strict_chain \
        proxy_dns \
        '' \
        'tcp_read_time_out 15000' \
        'tcp_connect_time_out 8000' \
        '' \
        '[ProxyList]' \
        'http 127.0.0.1 10808' >"$path"
end

# Echo the config path to stdout when it exists; otherwise explain on stderr,
# optionally offer to generate a template, and return 1. All diagnostics go to
# stderr so callers can capture the path via `(_proxychains_conf_ready)`.
# Idiom: `set -l conf (_proxychains_conf_ready); or return 1`.
function _proxychains_conf_ready
    set -l conf (_proxychains_conf)
    if test -f "$conf"
        echo "$conf"
        return 0
    end
    echo "[proxy] no config found at $conf" >&2
    if confirm "[proxy] generate a template there?"
        _proxychains_write_template "$conf"
        echo "[proxy] wrote template to $conf; edit it, then run 'proxy' again." >&2
    else
        echo "[proxy] create it, or run 'proxy' in an interactive shell to generate a template." >&2
    end
    return 1
end

# Echo the first usable [ProxyList] entry of $argv[1] as three lines (type, host,
# port); return 1 with no output when none is found. Skips blanks and #-comments.
function _proxychains_first_entry
    set -l in_list 0
    for line in (cat "$argv[1]" 2>/dev/null)
        if string match -qir '^\s*\[ProxyList\]\s*$' -- "$line"
            set in_list 1
            continue
        end
        test "$in_list" = 1; or continue
        set -l m (string match -r '^\s*(socks4|socks5|http)\s+(\S+)\s+(\S+)' -- "$line")
        if test (count $m) -ge 4
            echo "$m[2]"
            echo "$m[3]"
            echo "$m[4]"
            return 0
        end
    end
    return 1
end

# Return success when a TCP connection to host:port completes within ~1s. nc's
# connect-timeout flag differs by OS (BSD nc needs -G; OpenBSD/Linux nc does
# not), so branch on $DOTFILES_OS. When nc is missing, degrade silently (treat as
# reachable) so proxy still works — a per-shell-start nag would be worse.
function _proxychains_reachable
    has_cmd nc; or return 0
    switch $DOTFILES_OS
        case Darwin
            nc -z -G 1 -w 1 "$argv[1]" "$argv[2]" 2>/dev/null
        case '*'
            nc -z -w 1 "$argv[1]" "$argv[2]" 2>/dev/null
    end
end

# On macOS, warn when the target binary lives under a SIP-protected path. SIP
# strips DYLD_INSERT_LIBRARIES on exec for binaries under /usr (except
# /usr/local), /bin, /sbin and /System, so proxychains-ng cannot inject into
# them and the command silently runs un-proxied. Homebrew binaries (/opt/homebrew,
# /usr/local) are fine. Warns only; still runs the command.
function _proxychains_sip_warn
    test "$DOTFILES_OS" = Darwin; or return
    set -l bin (command -v -- $argv[1] 2>/dev/null)
    test -n "$bin"; or return
    if string match -qr '^/(usr/(?!local/)|bin/|sbin/|System/)' -- "$bin"
        echo "[prox] warning: '$argv[1]' → $bin is under macOS SIP protection." >&2
        echo "[prox]   SIP strips the DYLD injection proxychains needs, so this will NOT be proxied." >&2
        echo "[prox]   use a Homebrew build instead, e.g. 'brew install "(basename "$bin")"' (installs under /opt/homebrew)." >&2
    end
end

# Run a single command through proxychains-ng using ~/.config/proxychains.conf.
# Usage: prox curl https://example.com
function prox
    require_cmds proxychains4; or return 1

    set -l conf (_proxychains_conf_ready); or return 1

    if test (count $argv) -eq 0
        echo "[prox] usage: prox <command> [args...]" >&2
        return 2
    end

    _proxychains_sip_warn $argv[1]

    proxychains4 -f "$conf" $argv
end

# Set http/https/all proxy env vars from the first [ProxyList] entry of
# ~/.config/proxychains.conf. Called at shell start (guarded in config.fish) and
# manually. Probes the proxy first: if host:port is not reachable, warn and leave
# the env untouched rather than exporting a dead proxy.
function proxy
    set -l conf (_proxychains_conf_ready); or return 1

    set -l parts (_proxychains_first_entry "$conf")
    if test (count $parts) -ne 3
        echo "[proxy] no usable [ProxyList] entry in $conf" >&2
        return 1
    end
    set -l type $parts[1]
    set -l host $parts[2]
    set -l port $parts[3]

    if not _proxychains_reachable "$host" "$port"
        echo "[proxy] $host:$port not reachable; proxy env left unchanged." >&2
        return 1
    end

    # Map the entry to proxy URLs. Mirror the old behavior: an http server also
    # yields a socks5 all_proxy.
    set -l http_val
    set -l all_val
    switch $type
        case http
            set http_val "http://$host:$port"
            set all_val "socks5://$host:$port"
        case '*'
            set http_val "$type://$host:$port"
            set all_val "$type://$host:$port"
    end

    for var in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
        set -gx $var $http_val
    end
    for var in all_proxy ALL_PROXY
        set -gx $var $all_val
    end
end

function unproxy
    set -e all_proxy http_proxy https_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY
end
