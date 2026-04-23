#!/usr/bin/env zsh

case "$DOTFILES_OS" in
Darwin)
  run_if_cmd "/opt/homebrew/bin/brew" 'eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null)"'
  source_if_file "$HOME/.orbstack/shell/init.zsh"

  unsetopt hist_expand
  unsetopt hist_verify
  setopt no_nomatch
  ;;
Linux) ;;
esac

export FZF_CTRL_R_OPTS="--height 40% --reverse --border --preview 'echo {}' --preview-window=up:3:wrap"

run_if_cmd "zoxide" 'eval "$(zoxide init --cmd cd zsh)"'
source_if_file "$HOME/.config/zim/conf/setup_zim.zsh"