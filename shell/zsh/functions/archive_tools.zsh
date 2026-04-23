#!/usr/bin/env zsh

function compress7z() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: compress7z <file_or_dir>"
    return 1
  fi
  require_cmds 7z || return 1
  local file="$1"
  7z a -mmt "$file.7z" "$file"
}

function compress_zip() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: compress_zip <file_or_dir>"
    return 1
  fi
  require_cmds zip || return 1
  local file="$1"
  zip -r "$file.zip" "$file" -x "$file/build/*" "$file/third_party/*" "$file/.cache/*"
}

function compress_targz() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: compress_targz <file_or_dir>"
    return 1
  fi
  require_cmds tar || return 1
  local file="$1"
  tar -czvf "$file.tar.gz" "$file"
}

function decompress() {
  if [[ $# -lt 1 ]]; then
    echo "Usage: decompress <archive>"
    return 1
  fi
  local file="$1"
  local extension="${file##*.}"
  case "$extension" in
  tar)
    require_cmds tar || return 1
    tar -xvf "$file"
    ;;
  gz)
    require_cmds tar || return 1
    tar -xzvf "$file"
    ;;
  bz2)
    require_cmds tar || return 1
    tar -xjvf "$file"
    ;;
  xz)
    require_cmds tar || return 1
    tar -xJvf "$file"
    ;;
  zip)
    require_cmds unzip || return 1
    unzip "$file"
    ;;
  rar)
    require_cmds unrar || return 1
    unrar x "$file"
    ;;
  7z)
    require_cmds 7z || return 1
    7z x "$file"
    ;;
  *)
    echo "Unsupported file format: $extension"
    return 1
    ;;
  esac
}
