#!/usr/bin/env zsh

function get_conda_env() {
  echo -n "$CONDA_DEFAULT_ENV"
}

function kill_vscode() {
  case "$DOTFILES_OS" in
  Darwin)
    echo "kill_vscode is only needed on Linux for .vscode-server"
    ;;
  Linux)
    require_cmds ps awk xargs rg || return 1
    ps aux | rg ".vscode-server" | awk '{print $2}' | xargs kill
    ;;
  esac
}

function inherit_env() {
  if [[ "$DOTFILES_OS" != "Linux" ]]; then
    echo "inherit_env is only supported on Linux"
    return 1
  fi
  require_cmds sudo tr xargs bash || return 1
  sudo cat /proc/1/environ | tr '\0' '\n' |
    xargs -I {} bash -c 'v=$(echo "{}" | cut -d= -f1); [ -z "${!v}" ] && echo "export {}"; true' |
    source /dev/stdin
}

function compress_prologue() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: compress_prologue <path>"
    return 1
  fi
  require_cmds git awk paste sed rg || return 1
  local input_path="$1"
  if [[ -d "$input_path" ]] &&
    git -C "$input_path" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local root_path
    root_path="$(git -C "$input_path" rev-parse --show-toplevel)"
    local files_to_compress
    files_to_compress="$(git -C "$input_path" ls-files --others --exclude-standard --cached |
      rg -v "^$(git -C "$input_path" submodule--helper list | awk '{print $4}' | paste -sd '|' -)$" |
      sed "s|^|$root_path/|")"
    echo "Compressing files in git repository: $files_to_compress"
  fi
}
