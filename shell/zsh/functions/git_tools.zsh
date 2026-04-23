#!/usr/bin/env zsh

function stash_all_files() {
  require_cmds git || return 1
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "not inside a git work tree"
    return 1
  fi
  if [[ -z "$(git status --porcelain)" ]]; then
    echo "No files to stash"
    return 0
  fi
  git stash push -u -- ':(exclude)*.gitignore' ':(exclude).gitignore'
}
