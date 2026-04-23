#!/usr/bin/env zsh

export NVM_DIR="$HOME/.nvm"

# Lazy-load NVM on first use to keep login shells fast.
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  function _dotfiles_load_nvm() {
    unset -f nvm node npm npx _dotfiles_load_nvm 2>/dev/null
    source "$NVM_DIR/nvm.sh"
    source_if_file "$NVM_DIR/bash_completion"
  }
  function nvm() {
    _dotfiles_load_nvm
    nvm "$@"
  }
  function node() {
    _dotfiles_load_nvm
    node "$@"
  }
  function npm() {
    _dotfiles_load_nvm
    npm "$@"
  }
  function npx() {
    _dotfiles_load_nvm
    npx "$@"
  }
fi

if [[ -o interactive && -t 0 ]]; then
  run_if_cmd "fzf" "source <(fzf --zsh)"
fi
