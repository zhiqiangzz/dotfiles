# Fish entry point — the only file symlinked into ~/.config/fish (besides
# fish_plugins). Fish reads this for ALL shells (there is no .zshenv/.zshrc
# split), so it is a thin orchestrator: it bootstraps, then sources each stage
# in order, gating the interactive stage behind `status is-interactive`.
#
# The layered files are sourced by absolute path from $DOTFILES_FISH_HOME (not
# via fish's native conf.d/functions autoload) on purpose: fisher writes plugin
# files into ~/.config/fish/{functions,conf.d,completions}, so keeping our own
# config out of those dirs stops plugin churn from polluting this repo.
#
# Load order (see CLAUDE.md "Shell config architecture" for each stage's charter):
#   0. lib/guards      — helper vocabulary + cached OS/HOST identity  [all shells]
#   1. env/            — environment variables + PATH                 [all shells]
#   2. functions/      — function & command-wrapper DEFINITIONS       [all shells]
#   3. interactive/    — tool inits, prompt, keybindings, actions     [interactive]

set -gx DOTFILES_HOME "$HOME/.config/dotfiles"
set -gx DOTFILES_FISH_HOME "$DOTFILES_HOME/shell/fish"

# Stage 0 — must load first: defines the helpers (source_if_file, has_cmd,
# run_if_cmd, path_*_if_dir, …) and the DOTFILES_OS/HOST globals every stage
# below depends on. Definitions only, no side effects.
source "$DOTFILES_FISH_HOME/lib/guards.fish"

# Stage 1 — environment / PATH for all shells. base.fish chains os/$OS then
# host/$HOST (general → specific). Runs before stage 2/3 so PATH is set before
# any tool init probes for commands.
source_if_file "$DOTFILES_FISH_HOME/env/base.fish"

# Stage 2 — function & command-wrapper definitions for all shells. Defining is
# cheap and side-effect-free; startup *calls* (proxy, dotenv autoload) happen in
# stage 3. Kept out of the interactive gate so guards/wrappers also apply in
# scripts and non-interactive shells. base.fish owns the order of its own files.
source_if_file "$DOTFILES_FISH_HOME/functions/base.fish"

# Stage 3 — interactive only (fish's .zshrc analog). base.fish owns its own
# ordering (os layer → tool inits → zoxide last → startup actions).
if status is-interactive
    source_if_file "$DOTFILES_FISH_HOME/interactive/base.fish"
end
