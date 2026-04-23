#!/usr/bin/env zsh

function jqq() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: jqq <json_file>"
    return 1
  fi
  require_cmds jq || return 1
  local target="$1"
  if [[ ! -f "$target" ]]; then
    echo "File not found: $target"
    return 1
  fi
  local tmp
  tmp="$(mktemp)" || return 1
  if jq . "$target" >|"$tmp"; then
    mv "$tmp" "$target"
  else
    rm -f "$tmp"
    return 1
  fi
}

function shformat() {
  require_cmds shfmt fd || return 1

  local files
  files=("${(@f)$(fd -H --type f --regex '(\.sh$|\.zshrc$|\.zshenv$|\.zprofile$)')}")
  if ((!${#files})); then
    echo "No shell files found"
    return 0
  fi

  echo "The following files will be formatted:"
  printf '%s\n' "${files[@]}"
  echo -n "Are you sure you want to format these files? (yes/y to confirm): "
  read -r answer

  if [[ "$answer" =~ ^[Yy](es)?$ ]]; then
    shfmt -w -i 2 -- "${files[@]}"
    echo "'shfmt -w -i 2' applied to sh files successfully"
  else
    echo "Formatting cancelled"
  fi
}

function cformat() {
  require_cmds clang-format fd || return 1

  local files
  files=("${(@f)$(fd --type f --extension c --extension cpp --extension h --extension cc --extension hpp --extension cu)}")
  if ((!${#files})); then
    echo "No C/C++ files found"
    return 0
  fi

  echo "The following files will be formatted:"
  printf '%s\n' "${files[@]}"
  echo -n "Are you sure you want to format these files? (yes/y to confirm): "
  read -r answer

  if [[ "$answer" =~ ^[Yy](es)?$ ]]; then
    clang-format -i -- "${files[@]}"
    echo "clang-format applied to c/cpp/h/cc/hpp/cu files successfully"
  else
    echo "Formatting cancelled"
  fi
}
