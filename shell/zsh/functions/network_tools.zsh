#!/usr/bin/env zsh

# Detect public-IP country, caching result for 24h to avoid blocking shells.
function _dotfiles_ip_country() {
  require_cmds curl || return 1
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles"
  local cache_file="$cache_dir/ip_country"
  local now cached
  now="$(date +%s 2>/dev/null)"
  if [[ -f "$cache_file" ]]; then
    local mtime
    if [[ "$DOTFILES_OS" == "Darwin" ]]; then
      mtime="$(stat -f %m "$cache_file" 2>/dev/null)"
    else
      mtime="$(stat -c %Y "$cache_file" 2>/dev/null)"
    fi
    if [[ "$mtime" =~ '^[0-9]+$' && "$now" =~ '^[0-9]+$' ]] && ((now - mtime < 86400)); then
      cached="$(<"$cache_file")"
      if [[ -n "$cached" ]]; then
        printf '%s' "$cached"
        return 0
      fi
    fi
  fi
  if [[ -e "$cache_dir" && ! -d "$cache_dir" ]]; then
    return 1
  fi
  mkdir -p "$cache_dir" 2>/dev/null || return 1
  local country
  country="$(curl -fsS --max-time 2 https://ipinfo.io/country 2>/dev/null | tr -d '[:space:]')"
  if [[ -n "$country" ]]; then
    print -r -- "$country" >"$cache_file"
    printf '%s' "$country"
    return 0
  fi
  return 1
}

function proxy() {
  require_cmds curl || return 1

  local ip_country http_proxy_val all_proxy_val
  ip_country="$(_dotfiles_ip_country)"

  if [[ "$ip_country" == "CN" ]]; then
    http_proxy_val="${http_proxy_server:-http://127.0.0.1:10808}"
  else
    http_proxy_val="$http_proxy_server"
  fi

  if [[ -z "$http_proxy_val" ]]; then
    echo "[proxy] no proxy configured"
    return 0
  fi

  if [[ -n "$all_proxy_server" ]]; then
    all_proxy_val="$all_proxy_server"
  else
    all_proxy_val="${http_proxy_val/http:\/\//socks5://}"
  fi

  for var in http_proxy https_proxy HTTP_PROXY HTTPS_PROXY; do
    export $var="$http_proxy_val"
  done

  for var in all_proxy ALL_PROXY; do
    export $var="$all_proxy_val"
  done
}

function unproxy() {
  unset all_proxy http_proxy https_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY
}

function ippublic() {
  require_cmds curl || return 1
  curl ipinfo.io
}
