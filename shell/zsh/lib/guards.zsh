#!/usr/bin/env zsh

# Cached OS/host identity (avoid fork per shell / per function call).
if [[ -z "$DOTFILES_OS" ]]; then
  case "$OSTYPE" in
  darwin*) typeset -gx DOTFILES_OS="Darwin" ;;
  linux*) typeset -gx DOTFILES_OS="Linux" ;;
  *) typeset -gx DOTFILES_OS="$(uname)" ;;
  esac
fi
[[ -z "$DOTFILES_HOST" ]] && typeset -gx DOTFILES_HOST="${HOST%%.*}"

# Source a file only when it exists.
function source_if_file() {
  local file_path="$1"
  [[ -n "$file_path" && -f "$file_path" ]] && source "$file_path"
}

# Return success when a command exists in PATH.
function has_cmd() {
  command -v "$1" >/dev/null 2>&1
}

# Require one or more commands; reports all missing on stderr and returns 1.
function require_cmds() {
  local missing=()
  local c
  for c in "$@"; do
    has_cmd "$c" || missing+=("$c")
  done
  if (($#missing)); then
    print -u2 "missing commands: ${missing[*]}"
    return 1
  fi
}

# Run command string only when executable exists.
function run_if_cmd() {
  local exec_name="$1"
  local init_cmd="$2"
  if has_cmd "$exec_name"; then
    eval "$init_cmd"
  fi
}

# Append directory to PATH if it exists and not already included.
function path_append_if_dir() {
  local dir_path="$1"
  [[ -d "$dir_path" ]] || return 0
  case ":$PATH:" in
  *":$dir_path:"*) ;;
  *) export PATH="${PATH:+$PATH:}$dir_path" ;;
  esac
}

# Prepend directory to PATH if it exists and not already included.
function path_prepend_if_dir() {
  local dir_path="$1"
  [[ -d "$dir_path" ]] || return 0
  case ":$PATH:" in
  *":$dir_path:"*) ;;
  *) export PATH="$dir_path${PATH:+:$PATH}" ;;
  esac
}
