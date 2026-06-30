# Fish entry point — mirrors the old .zshenv/.zshrc load order.
#
# Fish reads this file for ALL shells (there is no .zshenv/.zshrc split), so
# environment/PATH setup runs unconditionally and interactive-only work is
# gated behind `status is-interactive`.
#
# Only this file and fish_plugins are symlinked into ~/.config/fish. The
# layered files below are sourced by absolute path from $DOTFILES_FISH_HOME,
# exactly as the zsh config sourced from $DOTFILES_SHELL_HOME.

set -gx DOTFILES_HOME "$HOME/.config/dotfiles"
set -gx DOTFILES_FISH_HOME "$DOTFILES_HOME/shell/fish"

# guards.fish must load first: it defines the helper vocabulary
# (source_if_file, has_cmd, run_if_cmd, path_*_if_dir) plus the cached
# DOTFILES_OS / DOTFILES_HOST globals that the rest of the config branches on.
source "$DOTFILES_FISH_HOME/lib/guards.fish"

# Environment / PATH: most-general to most-specific.
source_if_file "$DOTFILES_FISH_HOME/env/base.fish"
source_if_file "$DOTFILES_FISH_HOME/env/os/$DOTFILES_OS.fish"
source_if_file "$DOTFILES_FISH_HOME/env/host/$DOTFILES_HOST.fish"

# Interactive-only setup.
if status is-interactive
    source_if_file "$DOTFILES_FISH_HOME/functions/proxy.fish"
    source_if_file "$DOTFILES_FISH_HOME/login/base.fish"
    source_if_file "$DOTFILES_FISH_HOME/interactive/base.fish"
    proxy
end
