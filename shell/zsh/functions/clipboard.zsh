#!/usr/bin/env zsh

function cb_pwd() {
  if [[ "$DOTFILES_OS" != "Darwin" ]]; then
    echo "cb_pwd is only supported on Darwin"
    return 1
  fi
  require_cmds pbcopy || return 1
  local current_dir
  current_dir="$(pwd | sed "s|$HOME|~|g")"
  echo "$current_dir" | pbcopy
}

function cb_txt_file() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: cb_txt_file <file>"
    return 1
  fi
  if [[ "$DOTFILES_OS" != "Darwin" ]]; then
    echo "cb_txt_file is only supported on Darwin"
    return 1
  fi
  require_cmds pbcopy || return 1
  if [[ ! -f "$1" ]]; then
    echo "File not found: $1"
    return 1
  fi
  command cat "$1" | pbcopy
}
