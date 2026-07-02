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

# Environment / PATH. base.fish chains in the OS- and host-specific layers.
source_if_file "$DOTFILES_FISH_HOME/env/base.fish"

# Command wrappers guarded by egress country (all shells, so the guard applies
# regardless of interactivity; the function is cheap to define and the country
# probe only runs when a guarded command is actually invoked).
source_if_file "$DOTFILES_FISH_HOME/functions/guarded_commands.fish"

# Interactive-only setup.
if status is-interactive
    source_if_file "$DOTFILES_FISH_HOME/functions/proxy.fish"
    source_if_file "$DOTFILES_FISH_HOME/functions/dotenv.fish"
    source_if_file "$DOTFILES_FISH_HOME/login/base.fish"
    source_if_file "$DOTFILES_FISH_HOME/interactive/base.fish"
    # Only apply proxy env when a config exists, so a missing config doesn't
    # trigger the interactive "generate template?" prompt on every shell start.
    test -f "$HOME/.config/proxychains.conf"; and proxy
    # Load a .env in the directory the shell starts in (the PWD handler only
    # fires on subsequent cd).
    _dotenv_autoload
end
