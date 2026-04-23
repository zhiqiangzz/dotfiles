skip_global_compinit=1
HISTFILE=~/.zsh_history

export DOTFILES_HOME="$HOME/.config/dotfiles"
export DOTFILES_SHELL_HOME="$DOTFILES_HOME/shell/zsh"

[[ -n "$DOTFILES_PROFILE" ]] && zmodload zsh/zprof

[[ -f "$DOTFILES_SHELL_HOME/lib/guards.zsh" ]] && source "$DOTFILES_SHELL_HOME/lib/guards.zsh"

source_if_file "$DOTFILES_SHELL_HOME/env/base.zsh"
source_if_file "$DOTFILES_SHELL_HOME/env/os/$DOTFILES_OS.zsh"
source_if_file "$DOTFILES_SHELL_HOME/env/host/$DOTFILES_HOST.zsh"
