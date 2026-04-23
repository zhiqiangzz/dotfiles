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
  local ip_country
  ip_country="$(_dotfiles_ip_country)"

  if [[ "$ip_country" == "CN" ]]; then
    case "$DOTFILES_HOST" in
    zhiqiangzs-MacBook-Pro)
      export https_proxy="${http_proxy_server:-http://127.0.0.1:10808}"
      export http_proxy="${http_proxy_server:-http://127.0.0.1:10808}"
      export all_proxy="${all_proxy_server:-socks5://127.0.0.1:10808}"
      export HTTPS_PROXY="${http_proxy_server:-http://127.0.0.1:10808}"
      export HTTP_PROXY="${http_proxy_server:-http://127.0.0.1:10808}"
      export ALL_PROXY="${all_proxy_server:-socks5://127.0.0.1:10808}"
      ;;
    *) ;;
    esac
  else
    export https_proxy="$http_proxy_server"
    export http_proxy="$http_proxy_server"
    export all_proxy="$all_proxy_server"
    export HTTPS_PROXY="$http_proxy_server"
    export HTTP_PROXY="$http_proxy_server"
    export ALL_PROXY="$all_proxy_server"
  fi
}

function unproxy() {
  unset all_proxy http_proxy https_proxy HTTPS_PROXY HTTP_PROXY ALL_PROXY
}

function ippublic() {
  require_cmds curl || return 1
  curl ipinfo.io
}
