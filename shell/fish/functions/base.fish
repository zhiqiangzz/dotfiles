# Stage 2 entrypoint — function & command-wrapper DEFINITIONS for all shells.
# config.fish sources only this file (mirroring env/base.fish and
# interactive/base.fish); this module owns the order of its own files.
#
# Definitions only — no startup calls. Interactive invocations (the startup
# `proxy` call, `.env` autoload) live in interactive/base.fish.
source_if_file "$DOTFILES_FISH_HOME/functions/guarded_commands.fish"
source_if_file "$DOTFILES_FISH_HOME/functions/proxy.fish"
source_if_file "$DOTFILES_FISH_HOME/functions/dotenv.fish"
