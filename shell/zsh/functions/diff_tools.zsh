#!/usr/bin/env zsh

function dir_diff() {
  if [[ $# -ne 2 ]]; then
    echo "Usage: dir_diff <directory1> <directory2>"
    return 1
  fi

  local dir1="$1"
  local dir2="$2"

  if [[ ! -d "$dir1" || ! -d "$dir2" ]]; then
    echo "Both parameters should be directories"
    return 1
  fi

  local file
  for file in "$dir1"/*; do
    local filename
    filename="$(basename "$file")"
    if [[ -f "$dir2/$filename" ]]; then
      if ! diff "$file" "$dir2/$filename" >/dev/null; then
        echo "Difference found in file: $filename"
      fi
    fi
  done
}
