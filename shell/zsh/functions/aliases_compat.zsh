#!/usr/bin/env zsh

# Interactive shims: prefer modern tools without shadowing builtins in scripts.
has_cmd eza && alias ls='eza'

if [[ "$DOTFILES_OS" == "Darwin" ]]; then
  has_cmd bat && alias bcat='bat -p'
else
  if has_cmd batcat; then
    alias bcat='batcat -p'
  elif has_cmd bat; then
    alias bcat='bat -p'
  fi
  has_cmd fdfind && alias fd='fdfind'
fi

function iplocal() {
  case "$DOTFILES_OS" in
  Darwin)
    require_cmds ipconfig || return 1
    ipconfig getifaddr en0 || ipconfig getifaddr en1
    ;;
  Linux)
    require_cmds ip awk cut head || return 1
    ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1
    ;;
  esac
}
